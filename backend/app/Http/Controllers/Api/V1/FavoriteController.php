<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $favorites = Favorite::query()
            ->where('user_id', $request->user()->id)
            ->with('product.category')
            ->latest()
            ->get()
            ->pluck('product')
            ->filter(fn ($product) => $product->is_active && $product->is_available)
            ->values();

        return response()->json(['data' => $favorites]);
    }

    public function store(Request $request, Product $product): JsonResponse
    {
        abort_unless($product->is_active && $product->is_available && $product->category?->is_active, 404);

        Favorite::firstOrCreate([
            'user_id' => $request->user()->id,
            'product_id' => $product->id,
        ]);

        return response()->json(['data' => ['favorite' => true, 'product_id' => $product->id]]);
    }

    public function destroy(Request $request, Product $product): JsonResponse
    {
        Favorite::query()
            ->where('user_id', $request->user()->id)
            ->where('product_id', $product->id)
            ->delete();

        return response()->json(['data' => ['favorite' => false, 'product_id' => $product->id]]);
    }
}
