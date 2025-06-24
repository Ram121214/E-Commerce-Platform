"use client"

import { useState, useEffect } from "react"
import { useParams } from "next/navigation"
import { Star, Heart, ShoppingCart, Minus, Plus, Truck, Shield, RotateCcw } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent } from "@/components/ui/card"
import { Separator } from "@/components/ui/separator"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { getProductBySlug, type Product } from "@/lib/products"
import { addToCart } from "@/lib/cart"
import { supabase } from "@/lib/supabase"
import { toast } from "sonner"
import { ProductImageGallery } from "@/components/product-image-gallery"

export default function ProductPage() {
  const params = useParams()
  const [product, setProduct] = useState<Product | null>(null)
  const [loading, setLoading] = useState(true)
  const [quantity, setQuantity] = useState(1)
  const [isWishlisted, setIsWishlisted] = useState(false)

  useEffect(() => {
    if (params.slug) {
      loadProduct(params.slug as string)
    }
  }, [params.slug])

  const loadProduct = async (slug: string) => {
    try {
      const productData = await getProductBySlug(slug)
      setProduct(productData)
    } catch (error) {
      console.error("Error loading product:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleAddToCart = async () => {
    const {
      data: { user },
    } = await supabase.auth.getUser()
    if (!user) {
      toast.error("Please sign in to add items to cart")
      return
    }

    if (!product) return

    try {
      await addToCart(user.id, product.id, quantity)
      toast.success(`Added ${quantity} item(s) to cart!`)
    } catch (error) {
      toast.error("Failed to add to cart")
    }
  }

  const handleWishlist = async () => {
    const {
      data: { user },
    } = await supabase.auth.getUser()
    if (!user) {
      toast.error("Please sign in to add to wishlist")
      return
    }

    if (!product) return

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

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="text-center">Loading product...</div>
      </div>
    )
  }

  if (!product) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="text-center">Product not found</div>
      </div>
    )
  }

  const discountPercentage = product.compare_price
    ? Math.round(((product.compare_price - product.price) / product.compare_price) * 100)
    : 0

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
        {/* Product Images */}
        <div className="space-y-4">
          <ProductImageGallery images={product.images} productName={product.name} />
          {discountPercentage > 0 && (
            <Badge className="absolute top-4 left-4 bg-red-500 hover:bg-red-600 z-10">-{discountPercentage}%</Badge>
          )}
        </div>

        {/* Product Details */}
        <div className="space-y-6">
          <div>
            <h1 className="text-3xl font-bold mb-2">{product.name}</h1>
            <div className="flex items-center space-x-4 mb-4">
              <div className="flex items-center space-x-1">
                {[...Array(5)].map((_, i) => (
                  <Star
                    key={i}
                    className={`h-5 w-5 ${
                      i < Math.floor(product.rating) ? "text-yellow-400 fill-current" : "text-gray-300"
                    }`}
                  />
                ))}
                <span className="text-sm text-muted-foreground ml-2">({product.review_count} reviews)</span>
              </div>
            </div>
            <div className="flex items-center space-x-4 mb-6">
              <span className="text-3xl font-bold">${product.price}</span>
              {product.compare_price && (
                <span className="text-xl text-muted-foreground line-through">${product.compare_price}</span>
              )}
            </div>
          </div>

          <Separator />

          <div>
            <p className="text-muted-foreground leading-relaxed">{product.description}</p>
          </div>

          <div className="space-y-4">
            <div className="flex items-center space-x-4">
              <span className="font-medium">Quantity:</span>
              <div className="flex items-center space-x-2">
                <Button
                  variant="outline"
                  size="icon"
                  onClick={() => setQuantity(Math.max(1, quantity - 1))}
                  disabled={quantity <= 1}
                >
                  <Minus className="h-4 w-4" />
                </Button>
                <span className="w-12 text-center">{quantity}</span>
                <Button
                  variant="outline"
                  size="icon"
                  onClick={() => setQuantity(Math.min(product.stock_quantity, quantity + 1))}
                  disabled={quantity >= product.stock_quantity}
                >
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
              <span className="text-sm text-muted-foreground">{product.stock_quantity} in stock</span>
            </div>

            <div className="flex space-x-4">
              <Button onClick={handleAddToCart} disabled={product.stock_quantity === 0} className="flex-1" size="lg">
                <ShoppingCart className="mr-2 h-5 w-5" />
                {product.stock_quantity === 0 ? "Out of Stock" : "Add to Cart"}
              </Button>
              <Button
                variant="outline"
                size="lg"
                onClick={handleWishlist}
                className={isWishlisted ? "text-red-500 border-red-500" : ""}
              >
                <Heart className={`h-5 w-5 ${isWishlisted ? "fill-current" : ""}`} />
              </Button>
            </div>
          </div>

          <Separator />

          {/* Features */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                <Truck className="h-5 w-5 text-blue-600" />
              </div>
              <div>
                <p className="font-medium text-sm">Free Shipping</p>
                <p className="text-xs text-muted-foreground">On orders over $50</p>
              </div>
            </div>
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                <Shield className="h-5 w-5 text-green-600" />
              </div>
              <div>
                <p className="font-medium text-sm">Secure Payment</p>
                <p className="text-xs text-muted-foreground">100% protected</p>
              </div>
            </div>
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
                <RotateCcw className="h-5 w-5 text-orange-600" />
              </div>
              <div>
                <p className="font-medium text-sm">Easy Returns</p>
                <p className="text-xs text-muted-foreground">30-day policy</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      {product.category && <p className="text-sm text-muted-foreground">Category: {product.category.name}</p>}

      {/* Product Tabs */}
      <div className="mt-16">
        <Tabs defaultValue="description" className="w-full">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="description">Description</TabsTrigger>
            <TabsTrigger value="specifications">Specifications</TabsTrigger>
            <TabsTrigger value="reviews">Reviews</TabsTrigger>
          </TabsList>
          <TabsContent value="description" className="mt-6">
            <Card>
              <CardContent className="p-6">
                <p className="text-muted-foreground leading-relaxed">{product.description}</p>
              </CardContent>
            </Card>
          </TabsContent>
          <TabsContent value="specifications" className="mt-6">
            <Card>
              <CardContent className="p-6">
                <div className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <span className="font-medium">Category:</span>
                      <span className="ml-2 text-muted-foreground">{product.categories?.name}</span>
                    </div>
                    <div>
                      <span className="font-medium">Stock:</span>
                      <span className="ml-2 text-muted-foreground">{product.stock_quantity} units</span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
          <TabsContent value="reviews" className="mt-6">
            <Card>
              <CardContent className="p-6">
                <div className="text-center py-8">
                  <p className="text-muted-foreground">Reviews coming soon...</p>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
