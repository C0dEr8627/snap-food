<?php

namespace App\Http\Controllers\Api\V1\Catalogue;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreProductRequest;
use App\Http\Requests\UpdateProductRequest;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Gate;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        Gate::authorize('viewAny', Product::class);

        $query = Product::query()
            ->with('category')
            ->when(! $request->user()->hasRole('ADMIN'), fn ($query) => $query
                ->where('is_active', true)
                ->where('is_available', true)
                ->whereHas('category', fn ($category) => $category->where('is_active', true)))
            ->when($request->filled('category_id'), fn ($query) => $query->where('category_id', $request->integer('category_id')))
            ->when($request->filled('search'), fn ($query) => $query->where(function ($query) use ($request): void {
                $term = $request->string('search')->toString();
                $query->where('name', 'like', "%{$term}%")
                    ->orWhere('slug', 'like', "%{$term}%")
                    ->orWhere('description', 'like', "%{$term}%");
            }))
            ->orderBy('name');

        $perPage = min(max($request->integer('per_page', 20), 1), 100);

        return response()->json(['data' => $query->paginate($perPage)]);
    }

    public function show(Request $request, Product $product): JsonResponse
    {
        $this->authorize('view', $product);

        abort_unless(
            $request->user()->hasRole('ADMIN')
                || ($product->is_active && $product->is_available && $product->category?->is_active),
            404,
        );

        return response()->json(['data' => $product->load('category')]);
    }

    public function store(StoreProductRequest $request): JsonResponse
    {
        $product = Product::create($request->validated());

        return response()->json(['data' => $product->load('category')], 201);
    }

    public function update(UpdateProductRequest $request, Product $product): JsonResponse
    {
        $product->update($request->validated());

        return response()->json(['data' => $product->refresh()->load('category')]);
    }

    public function destroy(Request $request, Product $product): JsonResponse
    {
        $this->authorize('delete', $product);

        $product->update(['is_active' => false, 'is_available' => false]);

        return response()->json(['data' => $product->refresh()->load('category')]);
    }
}
