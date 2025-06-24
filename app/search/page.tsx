"use client"

import type React from "react"

import { useState, useEffect } from "react"
import { useSearchParams } from "next/navigation"
import { Search } from "lucide-react"
import { Input } from "@/components/ui/input"
import { ProductCard } from "@/components/product-card"
import { searchProducts, type Product } from "@/lib/products"

export default function SearchPage() {
  const searchParams = useSearchParams()
  const [products, setProducts] = useState<Product[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")

  const query = searchParams.get("q") || ""

  useEffect(() => {
    setSearchQuery(query)
    if (query) {
      performSearch(query)
    } else {
      setProducts([])
      setLoading(false)
    }
  }, [query])

  const performSearch = async (searchTerm: string) => {
    setLoading(true)
    try {
      const results = await searchProducts(searchTerm)
      setProducts(results)
    } catch (error) {
      console.error("Search error:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    if (searchQuery.trim()) {
      window.location.href = `/search?q=${encodeURIComponent(searchQuery.trim())}`
    }
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-2xl mx-auto mb-8">
        <form onSubmit={handleSearch} className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
          <Input
            type="search"
            placeholder="Search products..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10"
          />
        </form>
      </div>

      {query && (
        <div className="mb-6">
          <h1 className="text-2xl font-bold mb-2">Search Results</h1>
          <p className="text-muted-foreground">
            {loading ? "Searching..." : `${products.length} results for "${query}"`}
          </p>
        </div>
      )}

      {loading ? (
        <div className="text-center py-12">Loading...</div>
      ) : products.length === 0 && query ? (
        <div className="text-center py-12">
          <p className="text-muted-foreground">No products found for "{query}"</p>
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
