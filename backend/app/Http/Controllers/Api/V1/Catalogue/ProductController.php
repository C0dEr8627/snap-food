<?php

namespace App\Http\Controllers\Api\V1\Catalogue;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreProductRequest;
use App\Http\Requests\UpdateProductRequest;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

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
        Gate::authorize('view', $product);

        abort_unless(
            $request->user()->hasRole('ADMIN')
                || ($product->is_active && $product->is_available && $product->category?->is_active),
            404,
        );

        return response()->json(['data' => $product->load('category')]);
    }

    public function store(StoreProductRequest $request): JsonResponse
    {
        $data = $request->validated();

        // Keep creation compatible with older databases while migrations are deployed.
        if (! Schema::hasColumn('products', 'dietary')) {
            unset($data['dietary']);
        }
        if (! Schema::hasColumn('products', 'tags')) {
            unset($data['tags']);
        }

        $product = Product::create($data);

        return response()->json(['data' => $product->load('category')], 201);
    }

    public function update(UpdateProductRequest $request, Product $product): JsonResponse
    {
        $product->update($request->validated());

        return response()->json(['data' => $product->refresh()->load('category')]);
    }

    public function uploadImage(Request $request, Product $product): JsonResponse
    {
        Gate::authorize('update', $product);

        $request->validate([
            'image' => ['required', 'file', 'mimes:jpeg,jpg,png,webp', 'max:4096'],
        ]);

        $file = $request->file('image');
        $directory = public_path('uploads/products');
        if (! is_dir($directory)) {
            mkdir($directory, 0755, true);
        }

        $oldImage = $product->image;
        $filename = Str::uuid()->toString() . '.' . $file->extension();
        $file->move($directory, $filename);

        if (is_string($oldImage) && str_starts_with($oldImage, '/uploads/products/')) {
            $oldPath = public_path(ltrim($oldImage, '/'));
            if (is_file($oldPath)) {
                @unlink($oldPath);
            }
        }

        $product->update(['image' => '/uploads/products/' . $filename]);

        return response()->json(['data' => $product->refresh()->load('category')]);
    }

    public function destroy(Request $request, Product $product): JsonResponse
    {
        Gate::authorize('delete', $product);

        $product->update(['is_active' => false, 'is_available' => false]);

        return response()->json(['data' => $product->refresh()->load('category')]);
    }
}
