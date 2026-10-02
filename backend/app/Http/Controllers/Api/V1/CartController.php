<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\Cart;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CartController
{
    public function index(Request $request): JsonResponse
    {
        $items = Cart::query()
            ->where('user_id', $request->user()->id)
            ->with('product.category')
            ->orderBy('id')->get()
            ->filter(fn (Cart $item) =>
                $item->product !== null &&
                $item->product->is_active &&
                $item->product->is_available &&
                $item->product->category?->is_active
            )->values()->map(fn (Cart $item) => $this->serialize($item));

        return response()->json(['data' => $items]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_id' => ['required', 'integer', Rule::exists('products', 'id')->where(fn ($q) => $q->where('is_active', true)->where('is_available', true))],
            'quantity' => ['required', 'integer', 'min:1', 'max:99'],
        ]);

        $product = Product::query()->with('category')->findOrFail($validated['product_id']);
        abort_unless($product->is_active && $product->is_available && $product->category?->is_active, 422, 'This product is not available.');

        $cart = Cart::updateOrCreate(
            ['user_id' => $request->user()->id, 'product_id' => $product->id],
            ['quantity' => $validated['quantity']],
        );

        return response()->json(['data' => $this->serialize($cart->load('product.category'))]);
    }

    public function update(Request $request, Product $product): JsonResponse
    {
        $validated = $request->validate(['quantity' => ['required', 'integer', 'min:1', 'max:99']]);
        abort_unless($product->is_active && $product->is_available && $product->category?->is_active, 422, 'This product is not available.');

        $cart = Cart::query()->where('user_id', $request->user()->id)->where('product_id', $product->id)->firstOrFail();
        $cart->update(['quantity' => $validated['quantity']]);

        return response()->json(['data' => $this->serialize($cart->load('product.category'))]);
    }

    public function destroy(Request $request, Product $product): JsonResponse
    {
        Cart::query()->where('user_id', $request->user()->id)->where('product_id', $product->id)->delete();
        return response()->json(['data' => ['product_id' => $product->id, 'removed' => true]]);
    }

    public function clear(Request $request): JsonResponse
    {
        Cart::query()->where('user_id', $request->user()->id)->delete();
        return response()->json(['data' => ['cleared' => true]]);
    }

    private function serialize(Cart $cart): array
    {
        $product = $cart->product;
        return [
            'product_id' => (string) $cart->product_id,
            'name' => $product->name,
            'description' => $product->category?->name ?? 'Catalogue item',
            'preview_price' => (int) floor((float) $product->price),
            'quantity' => $cart->quantity,
            'vegetarian' => str_contains(strtolower($product->category?->name ?? ''), 'veg'),
            'image_url' => $product->image_url,
        ];
    }
}
