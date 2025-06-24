"use client"

import type React from "react"

import { useState } from "react"
import Image from "next/image"
import Link from "next/link"
import { Heart, ShoppingCart, Star } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent } from "@/components/ui/card"
import type { Product } from "@/lib/products"
import { addToCart } from "@/lib/cart"
import { supabase } from "@/lib/supabase"
import { toast } from "sonner"

interface ProductCardProps {
  product: Product
}

export function ProductCard({ product }: ProductCardProps) {
  const [isLoading, setIsLoading] = useState(false)
  const [isWishlisted, setIsWishlisted] = useState(false)

  const handleAddToCart = async (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()

    const {
      data: { user },
    } = await supabase.auth.getUser()
    if (!user) {
      toast.error("Please sign in to add items to cart")
      return
    }

    setIsLoading(true)
    try {
      await addToCart(user.id, product.id)
      toast.success("Added to cart!")
    } catch (error) {
      toast.error("Failed to add to cart")
    } finally {
      setIsLoading(false)
    }
  }

  const handleWishlist = async (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()

    const {
      data: { user },
    } = await supabase.auth.getUser()
    if (!user) {
      toast.error("Please sign in to add to wishlist")
      return
    }

    try {
      if (isWishlisted) {
        await supabase.from("wishlist").delete().eq("user_id", user.id).eq("product_id", product.id)
        setIsWishlisted(false)
        toast.success("Removed from wishlist")
      } else {
        await supabase.from("wishlist").insert({ user_id: user.id, product_id: product.id })
        setIsWishlisted(true)
        toast.success("Added to wishlist")
      }
    } catch (error) {
      toast.error("Failed to update wishlist")
    }
  }

  const discountPercentage = product.compare_price
    ? Math.round(((product.compare_price - product.price) / product.compare_price) * 100)
    : 0

  return (
    <Link href={`/product/${product.slug}`}>
      <Card className="group overflow-hidden hover:shadow-lg transition-shadow duration-300">
        <div className="relative aspect-square overflow-hidden">
          <Image
            src={product.image_url || "/placeholder.svg?height=400&width=400"}
            alt={product.name}
            fill
            className="object-cover group-hover:scale-105 transition-transform duration-300"
            sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 25vw"
          />
          {discountPercentage > 0 && (
            <Badge className="absolute top-2 left-2 bg-red-500 hover:bg-red-600">-{discountPercentage}%</Badge>
          )}
          <Button
            variant="ghost"
            size="icon"
            className={`absolute top-2 right-2 h-8 w-8 rounded-full bg-white/80 hover:bg-white ${
              isWishlisted ? "text-red-500" : "text-gray-600"
            }`}
            onClick={handleWishlist}
          >
            <Heart className={`h-4 w-4 ${isWishlisted ? "fill-current" : ""}`} />
          </Button>
        </div>

        <CardContent className="p-4">
          <div className="space-y-2">
            <h3 className="font-semibold text-sm line-clamp-2 group-hover:text-primary transition-colors">
              {product.name}
            </h3>

            {product.category && <p className="text-xs text-muted-foreground">{product.category.name}</p>}

            <div className="flex items-center space-x-1">
              <div className="flex items-center">
                {[...Array(5)].map((_, i) => (
                  <Star
                    key={i}
                    className={`h-3 w-3 ${
                      i < Math.floor(product.rating) ? "text-yellow-400 fill-current" : "text-gray-300"
                    }`}
                  />
                ))}
              </div>
              <span className="text-xs text-muted-foreground">({product.review_count})</span>
            </div>

            <div className="flex items-center space-x-2">
              <span className="font-bold text-lg">${product.price}</span>
              {product.compare_price && (
                <span className="text-sm text-muted-foreground line-through">${product.compare_price}</span>
              )}
            </div>

            <Button
              onClick={handleAddToCart}
              disabled={isLoading || product.stock_quantity === 0}
              className="w-full"
              size="sm"
            >
              <ShoppingCart className="mr-2 h-4 w-4" />
              {product.stock_quantity === 0 ? "Out of Stock" : "Add to Cart"}
            </Button>
          </div>
        </CardContent>
      </Card>
    </Link>
  )
}
