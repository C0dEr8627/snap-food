<?php

namespace App\Http\Controllers\Api\V1\Catalogue;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCategoryRequest;
use App\Http\Requests\UpdateCategoryRequest;
use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Category::class);

        $query = Category::query()
            ->when(! $request->user()->hasRole('ADMIN'), fn ($query) => $query->where('is_active', true))
            ->when($request->filled('search'), fn ($query) => $query->where(function ($query) use ($request): void {
                $term = $request->string('search')->toString();
                $query->where('name', 'like', "%{$term}%")
                    ->orWhere('slug', 'like', "%{$term}%");
            }))
            ->orderBy('sort_order')
            ->orderBy('name');

        $perPage = min(max($request->integer('per_page', 20), 1), 100);

        return response()->json(['data' => $query->paginate($perPage)]);
    }

    public function show(Request $request, Category $category): JsonResponse
    {
        $this->authorize('view', $category);

        abort_unless($request->user()->hasRole('ADMIN') || $category->is_active, 404);

        return response()->json(['data' => $category]);
    }

    public function store(StoreCategoryRequest $request): JsonResponse
    {
        $category = Category::create($request->validated());

        return response()->json(['data' => $category], 201);
    }

    public function update(UpdateCategoryRequest $request, Category $category): JsonResponse
    {
        $category->update($request->validated());

        return response()->json(['data' => $category->refresh()]);
    }

    public function destroy(Request $request, Category $category): JsonResponse
    {
        $this->authorize('delete', $category);

        $category->update(['is_active' => false]);

        return response()->json(['data' => $category->refresh()]);
    }
}
