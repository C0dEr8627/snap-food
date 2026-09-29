<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;

class CatalogueController extends Controller
{
    public function index(Request $request): View
    {
        $validated = $request->validate([
            'q' => ['nullable', 'string', 'max:120'],
            'type' => ['nullable', 'in:all,categories,products'],
        ]);
        $term = $validated['q'] ?? '';
        $type = $validated['type'] ?? 'all';

        $categories = Category::query()
            ->when($type === 'products', fn ($query) => $query->whereRaw('1 = 0'))
            ->when($term !== '', fn ($query) => $query->where(function ($query) use ($term): void {
                $query->where('name', 'like', "%{$term}%")->orWhere('slug', 'like', "%{$term}%");
            }))
            ->withCount('products')->orderBy('sort_order')->orderBy('name')->paginate(15, ['*'], 'categories_page')->withQueryString();

        $products = Product::query()->with('category')
            ->when($type === 'categories', fn ($query) => $query->whereRaw('1 = 0'))
            ->when($term !== '', fn ($query) => $query->where(function ($query) use ($term): void {
                $query->where('name', 'like', "%{$term}%")
                    ->orWhere('slug', 'like', "%{$term}%")
                    ->orWhereHas('category', fn ($category) => $category->where('name', 'like', "%{$term}%"));
            }))
            ->orderBy('name')->paginate(15, ['*'], 'products_page')->withQueryString();

        $categoryOptions = Category::query()->orderBy('sort_order')->orderBy('name')->get(['id', 'name']);

        return view('admin.catalogue.index', compact('categories', 'products', 'categoryOptions', 'validated'));
    }

    public function storeCategory(Request $request): RedirectResponse
    {
        Gate::authorize('create', Category::class);
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'slug' => ['required', 'string', 'max:140', 'alpha_dash', Rule::unique('categories', 'slug')],
            'image' => ['nullable', 'url', 'max:2048'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ]);
        $validated['is_active'] = $request->boolean('is_active');
        Category::create($validated);

        return redirect()->route('admin.catalogue.index')->with('status', 'Category created.');
    }

    public function updateCategory(Request $request, Category $category): RedirectResponse
    {
        Gate::authorize('update', $category);
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'slug' => ['required', 'string', 'max:140', 'alpha_dash', Rule::unique('categories', 'slug')->ignore($category->id)],
            'image' => ['nullable', 'url', 'max:2048'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ]);
        $validated['is_active'] = $request->boolean('is_active');
        $category->update($validated);

        return redirect()->route('admin.catalogue.index')->with('status', 'Category updated.');
    }

    public function storeProduct(Request $request): RedirectResponse
    {
        Gate::authorize('create', Product::class);
        $validated = $request->validate([
            'category_id' => ['required', 'integer', 'exists:categories,id'],
            'name' => ['required', 'string', 'max:180'],
            'slug' => ['required', 'string', 'max:200', 'alpha_dash', Rule::unique('products', 'slug')],
            'description' => ['nullable', 'string'],
            'price' => ['required', 'numeric', 'decimal:0,2', 'min:0'],
            'image' => ['nullable', 'url', 'max:2048'],
            'stock_quantity' => ['nullable', 'integer', 'min:0'],
        ]);
        $validated['is_available'] = $request->boolean('is_available');
        $validated['is_active'] = $request->boolean('is_active');
        Product::create($validated);

        return redirect()->route('admin.catalogue.index')->with('status', 'Product created.');
    }

    public function updateProduct(Request $request, Product $product): RedirectResponse
    {
        Gate::authorize('update', $product);
        $validated = $request->validate([
            'category_id' => ['required', 'integer', 'exists:categories,id'],
            'name' => ['required', 'string', 'max:180'],
            'slug' => ['required', 'string', 'max:200', 'alpha_dash', Rule::unique('products', 'slug')->ignore($product->id)],
            'description' => ['nullable', 'string'],
            'price' => ['required', 'numeric', 'decimal:0,2', 'min:0'],
            'image' => ['nullable', 'url', 'max:2048'],
            'stock_quantity' => ['nullable', 'integer', 'min:0'],
        ]);
        $validated['is_available'] = $request->boolean('is_available');
        $validated['is_active'] = $request->boolean('is_active');
        $product->update($validated);

        return redirect()->route('admin.catalogue.index')->with('status', 'Product updated.');
    }

    public function deactivateCategory(Category $category): RedirectResponse
    {
        Gate::authorize('delete', $category);
        $category->update(['is_active' => false]);

        return redirect()->route('admin.catalogue.index')->with('status', 'Category deactivated.');
    }

    public function deactivateProduct(Product $product): RedirectResponse
    {
        Gate::authorize('delete', $product);
        $product->update(['is_active' => false, 'is_available' => false]);

        return redirect()->route('admin.catalogue.index')->with('status', 'Product deactivated.');
    }
}
