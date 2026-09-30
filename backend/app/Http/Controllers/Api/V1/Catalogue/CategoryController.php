<?php

namespace App\Http\Controllers\Api\V1\Catalogue;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCategoryRequest;
use App\Http\Requests\UpdateCategoryRequest;
use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class CategoryController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        Gate::authorize('viewAny', Category::class);

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
        Gate::authorize('view', $category);

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
        Gate::authorize('delete', $category);

        if ($category->products()->exists()) {
            return response()->json([
                'message' => 'Category cannot be permanently deleted while products are assigned to it. Deactivate it instead or move its products first.',
            ], 409);
        }

        $category->delete();

        return response()->json(['data' => ['id' => $category->id, 'deleted' => true]]);
    }
}
