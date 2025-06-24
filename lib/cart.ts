import { supabase } from "./supabase"

export interface CartItem {
  id: string
  user_id: string
  product_id: string
  quantity: number
  created_at: string
  products: {
    id: string
    name: string
    price: number
    image_url: string
    stock_quantity: number
  }
}

export async function getCartItems(userId: string) {
  const { data, error } = await supabase
    .from("cart_items")
    .select(`
      *,
      products (
        id,
        name,
        price,
        image_url,
        stock_quantity
      )
    `)
    .eq("user_id", userId)

  if (error) throw error
  return data as CartItem[]
}

export async function addToCart(userId: string, productId: string, quantity = 1) {
  const { data, error } = await supabase.from("cart_items").upsert(
    {
      user_id: userId,
      product_id: productId,
      quantity,
    },
    {
      onConflict: "user_id,product_id",
    },
  )

  if (error) throw error
  return data
}

export async function updateCartItem(userId: string, productId: string, quantity: number) {
  if (quantity <= 0) {
    return removeFromCart(userId, productId)
  }

  const { data, error } = await supabase
    .from("cart_items")
    .update({ quantity })
    .eq("user_id", userId)
    .eq("product_id", productId)

  if (error) throw error
  return data
}

export async function removeFromCart(userId: string, productId: string) {
  const { data, error } = await supabase.from("cart_items").delete().eq("user_id", userId).eq("product_id", productId)

  if (error) throw error
  return data
}

export async function clearCart(userId: string) {
  const { data, error } = await supabase.from("cart_items").delete().eq("user_id", userId)

  if (error) throw error
  return data
}
