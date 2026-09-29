<?php

namespace Tests\Feature;

use App\Models\Invoice;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class InvoiceApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_delivered_customer_can_generate_and_read_invoice_from_order_snapshots(): void
    {
        $customer = User::factory()->create(['role' => User::ROLE_CUSTOMER]);
        $order = Order::factory()->create([
            'customer_id' => $customer->id,
            'status' => Order::STATUS_DELIVERED,
            'subtotal' => '100.00',
            'delivery_fee' => '20.00',
            'total' => '120.00',
            'payment_method' => Order::PAYMENT_METHOD_COD,
            'payment_status' => Order::PAYMENT_STATUS_PENDING,
            'delivery_address_snapshot' => ['line1' => '10 Test Street'],
        ]);
        OrderItem::factory()->create([
            'order_id' => $order->id,
            'product_id' => null,
            'product_name' => 'Pizza',
            'unit_price' => '100.00',
            'quantity' => 1,
            'line_total' => '100.00',
        ]);

        Sanctum::actingAs($customer);

        $response = $this->getJson("/api/v1/orders/{$order->id}/invoice");

        $response->assertOk()
            ->assertJsonPath('data.invoice_number', sprintf('INV-%s-%08d', now()->format('Y'), $order->id))
            ->assertJsonPath('data.total', '120.00')
            ->assertJsonPath('data.items.0.product_name', 'Pizza');

        $this->assertDatabaseHas('invoices', [
            'order_id' => $order->id,
            'invoice_number' => sprintf('INV-%s-%08d', now()->format('Y'), $order->id),
        ]);
    }

    public function test_invoice_uses_immutable_snapshot_after_order_changes(): void
    {
        $customer = User::factory()->create(['role' => User::ROLE_CUSTOMER]);
        $order = Order::factory()->create([
            'customer_id' => $customer->id,
            'status' => Order::STATUS_DELIVERED,
            'subtotal' => '50.00',
            'delivery_fee' => '10.00',
            'total' => '60.00',
            'delivery_address_snapshot' => ['line1' => 'Original'],
        ]);
        Sanctum::actingAs($customer);

        $this->getJson("/api/v1/orders/{$order->id}/invoice")->assertOk();

        $order->update([
            'subtotal' => '999.00',
            'delivery_fee' => '1.00',
            'total' => '1000.00',
            'delivery_address_snapshot' => ['line1' => 'Changed'],
        ]);

        $invoice = Invoice::query()->where('order_id', $order->id)->firstOrFail();

        $this->assertSame('50.00', $invoice->subtotal);
        $this->assertSame('10.00', $invoice->delivery_fee);
        $this->assertSame('60.00', $invoice->total);
        $this->assertSame('Original', $invoice->delivery_address_snapshot['line1']);
    }

    public function test_invoice_requires_delivered_order(): void
    {
        $customer = User::factory()->create(['role' => User::ROLE_CUSTOMER]);
        $order = Order::factory()->create([
            'customer_id' => $customer->id,
            'status' => Order::STATUS_OUT_FOR_DELIVERY,
        ]);
        Sanctum::actingAs($customer);

        $this->getJson("/api/v1/orders/{$order->id}/invoice")
            ->assertStatus(409)
            ->assertJsonPath('code', 'CONFLICT');
    }

    public function test_other_customer_cannot_read_invoice(): void
    {
        $owner = User::factory()->create(['role' => User::ROLE_CUSTOMER]);
        $other = User::factory()->create(['role' => User::ROLE_CUSTOMER]);
        $order = Order::factory()->create([
            'customer_id' => $owner->id,
            'status' => Order::STATUS_DELIVERED,
        ]);
        Sanctum::actingAs($other);

        $this->getJson("/api/v1/orders/{$order->id}/invoice")
            ->assertStatus(403)
            ->assertJsonPath('code', 'FORBIDDEN');
    }

    public function test_delivery_partner_cannot_read_invoice(): void
    {
        $customer = User::factory()->create(['role' => User::ROLE_CUSTOMER]);
        $partner = User::factory()->create(['role' => User::ROLE_DELIVERY_PARTNER]);
        $order = Order::factory()->create([
            'customer_id' => $customer->id,
            'status' => Order::STATUS_DELIVERED,
        ]);
        Sanctum::actingAs($partner);

        $this->getJson("/api/v1/orders/{$order->id}/invoice")
            ->assertStatus(403)
            ->assertJsonPath('code', 'FORBIDDEN');
    }

    public function test_admin_can_read_delivered_order_invoice(): void
    {
        $admin = User::factory()->create(['role' => User::ROLE_ADMIN]);
        $customer = User::factory()->create(['role' => User::ROLE_CUSTOMER]);
        $order = Order::factory()->create([
            'customer_id' => $customer->id,
            'status' => Order::STATUS_DELIVERED,
        ]);
        Sanctum::actingAs($admin);

        $this->getJson("/api/v1/admin/orders/{$order->id}/invoice")
            ->assertOk()
            ->assertJsonPath('data.order_id', $order->id);
    }

    public function test_invoice_number_is_unique_and_generation_is_idempotent(): void
    {
        $customer = User::factory()->create(['role' => User::ROLE_CUSTOMER]);
        $order = Order::factory()->create([
            'customer_id' => $customer->id,
            'status' => Order::STATUS_DELIVERED,
        ]);
        Sanctum::actingAs($customer);

        $first = $this->getJson("/api/v1/orders/{$order->id}/invoice")->assertOk()->json('data');
        $second = $this->getJson("/api/v1/orders/{$order->id}/invoice")->assertOk()->json('data');

        $this->assertSame($first['id'], $second['id']);
        $this->assertSame($first['invoice_number'], $second['invoice_number']);
        $this->assertDatabaseCount('invoices', 1);
    }
}
