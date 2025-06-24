"use client"

import { useState, useEffect } from "react"
import { useParams } from "next/navigation"
import { ProductCard } from "@/components/product-card"
import { getProductsByCategory, getCategories, type Product, type Category } from "@/lib/products"

export default function CategoryPage() {
  const params = useParams()
  const [products, setProducts] = useState<Product[]>([])
  const [category, setCategory] = useState<Category | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (params.slug) {
      loadCategoryData(params.slug as string)
    }
  }, [params.slug])

  const loadCategoryData = async (slug: string) => {
    try {
      const [productsData, categoriesData] = await Promise.all([getProductsByCategory(slug), getCategories()])

      setProducts(productsData)
      const categoryData = categoriesData.find((cat) => cat.slug === slug)
      setCategory(categoryData || null)
    } catch (error) {
      console.error("Error loading category data:", error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="text-center">Loading category...</div>
      </div>
    )
  }

  if (!category) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="text-center">Category not found</div>
      </div>
    )
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">{category.name}</h1>
        <p className="text-muted-foreground">{category.description}</p>
        <p className="text-sm text-muted-foreground mt-2">{products.length} products found</p>
      </div>

      {products.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-muted-foreground">No products found in this category.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {products.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      )}
    </div>
  )
}
