<?php

namespace Tests\Feature;

use App\Models\DeliveryPartner;
use App\Models\Invoice;
use App\Models\Order;
use App\Models\OrderAssignment;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminOperationsWebTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_search_customers_and_filter_delivery_partners(): void
    {
        $admin = User::factory()->admin()->create();
        $customer = User::factory()->create(['name' => 'Mira Customer', 'email' => 'mira@example.test']);
        $partnerUser = User::factory()->deliveryPartner()->create(['name' => 'Ravi Rider']);
        $partner = DeliveryPartner::create([
            'user_id' => $partnerUser->id,
            'is_approved' => true,
            'is_active' => true,
            'is_available' => true,
            'approved_at' => now(),
        ]);

        $this->actingAs($admin, 'web')
            ->get('/admin/customers?q=mira')
            ->assertOk()
            ->assertSee('Mira Customer')
            ->assertDontSee('Ravi Rider');

        $this->actingAs($admin, 'web')
            ->get('/admin/delivery-partners?state=available')
            ->assertOk()
            ->assertSee('Ravi Rider')
            ->assertSee('Available');
    }

    public function test_admin_can_review_assignments_and_existing_invoices(): void
    {
        $admin = User::factory()->admin()->create();
        $customer = User::factory()->create(['name' => 'Invoice Customer']);
        $partnerUser = User::factory()->deliveryPartner()->create(['name' => 'Assigned Rider']);
        $partner = DeliveryPartner::create([
            'user_id' => $partnerUser->id,
            'is_approved' => true,
            'is_active' => true,
            'is_available' => false,
            'approved_at' => now(),
        ]);
        $order = Order::factory()->create(['customer_id' => $customer->id, 'status' => Order::STATUS_DELIVERED]);
        OrderAssignment::create([
            'order_id' => $order->id,
            'delivery_partner_id' => $partner->id,
            'assigned_by' => $admin->id,
            'assigned_at' => now(),
        ]);
        Invoice::create([
            'order_id' => $order->id,
            'invoice_number' => 'INV-2026-'.str_pad((string) $order->id, 8, '0', STR_PAD_LEFT),
            'customer_name' => $customer->name,
            'customer_email' => $customer->email,
            'delivery_address_snapshot' => ['line1' => '1 Test Street'],
            'items_snapshot' => [['product_name' => 'Test Meal', 'quantity' => 1, 'unit_price' => '100.00', 'line_total' => '100.00']],
            'subtotal' => '100.00',
            'delivery_fee' => '10.00',
            'total' => '110.00',
            'payment_method' => 'COD',
            'payment_status' => 'PENDING',
            'issued_at' => now(),
        ]);

        $this->actingAs($admin, 'web')
            ->get('/admin/assignments?status=DELIVERED')
            ->assertOk()
            ->assertSee('Assigned Rider')
            ->assertSee('Invoice Customer');

        $this->actingAs($admin, 'web')
            ->get('/admin/invoices?q=Invoice')
            ->assertOk()
            ->assertSee('INV-2026-')
            ->assertSee('Test Meal')
            ->assertSee('Invoice Customer');
    }

    public function test_admin_can_approve_revoke_and_change_delivery_partner_state(): void
    {
        $admin = User::factory()->admin()->create();
        $partnerUser = User::factory()->deliveryPartner()->create();
        $partner = DeliveryPartner::create([
            'user_id' => $partnerUser->id,
            'is_approved' => false,
            'is_active' => true,
            'is_available' => false,
        ]);

        $this->actingAs($admin, 'web')
            ->post('/admin/delivery-partners/'.$partner->id.'/approval', ['approved' => '1'])
            ->assertRedirect('/admin/delivery-partners');

        $this->assertDatabaseHas('delivery_partners', [
            'id' => $partner->id,
            'is_approved' => true,
            'approved_by' => $admin->id,
        ]);

        $this->actingAs($admin, 'web')
            ->post('/admin/delivery-partners/'.$partner->id.'/state', ['action' => 'available'])
            ->assertRedirect('/admin/delivery-partners');

        $this->assertDatabaseHas('delivery_partners', ['id' => $partner->id, 'is_available' => true]);

        $this->actingAs($admin, 'web')
            ->post('/admin/delivery-partners/'.$partner->id.'/approval', ['approved' => '0'])
            ->assertRedirect('/admin/delivery-partners');

        $this->assertDatabaseHas('delivery_partners', [
            'id' => $partner->id,
            'is_approved' => false,
            'is_available' => false,
            'approved_by' => null,
        ]);

        $this->actingAs($admin, 'web')
            ->post('/admin/delivery-partners/'.$partner->id.'/state', ['action' => 'deactivate'])
            ->assertRedirect('/admin/delivery-partners');

        $this->assertDatabaseHas('delivery_partners', ['id' => $partner->id, 'is_active' => false, 'is_available' => false]);
    }

    public function test_unapproved_partner_cannot_be_marked_available(): void
    {
        $admin = User::factory()->admin()->create();
        $partnerUser = User::factory()->deliveryPartner()->create();
        $partner = DeliveryPartner::create([
            'user_id' => $partnerUser->id,
            'is_approved' => false,
            'is_active' => true,
            'is_available' => false,
        ]);

        $this->actingAs($admin, 'web')
            ->from('/admin/delivery-partners')
            ->post('/admin/delivery-partners/'.$partner->id.'/state', ['action' => 'available'])
            ->assertConflict();

        $this->assertDatabaseHas('delivery_partners', ['id' => $partner->id, 'is_available' => false]);
    }

    public function test_customer_cannot_access_admin_operations_pages(): void
    {
        $customer = User::factory()->create();

        foreach (['/admin/customers', '/admin/delivery-partners', '/admin/assignments', '/admin/invoices'] as $path) {
            $this->actingAs($customer, 'web')->get($path)->assertForbidden();
        }
    }
}
