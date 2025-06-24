import { supabase } from "./supabase"

export interface Product {
  id: string
  name: string
  slug: string
  description: string
  price: number
  compare_price?: number
  category_id: string
  image_url: string
  images: string[]
  stock_quantity: number
  is_featured: boolean
  is_active: boolean
  rating: number
  review_count: number
  created_at: string
  category?: {
    name: string
    slug: string
  }
}

export interface Category {
  id: string
  name: string
  slug: string
  description: string
  image_url: string
}

export async function getProducts(filters?: {
  category?: string
  minPrice?: number
  maxPrice?: number
  featured?: boolean
  limit?: number
}) {
  // First, get products
  let query = supabase.from("products").select("*").eq("is_active", true)

  if (filters?.category && filters.category !== "all") {
    // Get category ID first
    const { data: categoryData } = await supabase.from("categories").select("id").eq("slug", filters.category).single()

    if (categoryData) {
      query = query.eq("category_id", categoryData.id)
    }
  }

  if (filters?.minPrice) {
    query = query.gte("price", filters.minPrice)
  }

  if (filters?.maxPrice) {
    query = query.lte("price", filters.maxPrice)
  }

  if (filters?.featured) {
    query = query.eq("is_featured", true)
  }

  if (filters?.limit) {
    query = query.limit(filters.limit)
  }

  const { data: products, error } = await query.order("created_at", { ascending: false })

  if (error) throw error

  // Get categories for the products
  const categoryIds = [...new Set(products.map((p) => p.category_id))]
  const { data: categories } = await supabase.from("categories").select("id, name, slug").in("id", categoryIds)

  // Combine products with category data
  const productsWithCategories = products.map((product) => ({
    ...product,
    category: categories?.find((cat) => cat.id === product.category_id),
  }))

  return productsWithCategories as Product[]
}

export async function getProductBySlug(slug: string) {
  const { data: product, error } = await supabase
    .from("products")
    .select("*")
    .eq("slug", slug)
    .eq("is_active", true)
    .single()

  if (error) throw error

  // Get category data
  const { data: category } = await supabase
    .from("categories")
    .select("name, slug")
    .eq("id", product.category_id)
    .single()

  return {
    ...product,
    category,
  } as Product
}

export async function getProductsByCategory(categorySlug: string) {
  // First get the category
  const { data: category, error: categoryError } = await supabase
    .from("categories")
    .select("id")
    .eq("slug", categorySlug)
    .single()

  if (categoryError) throw categoryError

  const { data: products, error } = await supabase
    .from("products")
    .select("*")
    .eq("category_id", category.id)
    .eq("is_active", true)
    .order("created_at", { ascending: false })

  if (error) throw error

  // Get category data for display
  const { data: categoryData } = await supabase.from("categories").select("name, slug").eq("id", category.id).single()

  // Add category to each product
  const productsWithCategory = products.map((product) => ({
    ...product,
    category: categoryData,
  }))

  return productsWithCategory as Product[]
}

export async function getCategories() {
  const { data, error } = await supabase.from("categories").select("*").order("name")

  if (error) throw error
  return data as Category[]
}

export async function getFeaturedProducts(limit = 8) {
  return getProducts({ featured: true, limit })
}

export async function searchProducts(query: string) {
  const { data: products, error } = await supabase
    .from("products")
    .select("*")
    .eq("is_active", true)
    .ilike("name", `%${query}%`)
    .limit(10)

  if (error) throw error

  // Get categories for the products
  const categoryIds = [...new Set(products.map((p) => p.category_id))]
  const { data: categories } = await supabase.from("categories").select("id, name, slug").in("id", categoryIds)

  // Combine products with category data
  const productsWithCategories = products.map((product) => ({
    ...product,
    category: categories?.find((cat) => cat.id === product.category_id),
  }))

  return productsWithCategories as Product[]
}
