-- Drop existing tables to recreate with proper relationships
DROP TABLE IF EXISTS public.cart_items CASCADE;
DROP TABLE IF EXISTS public.order_items CASCADE;
DROP TABLE IF EXISTS public.reviews CASCADE;
DROP TABLE IF EXISTS public.wishlist CASCADE;
DROP TABLE IF EXISTS public.products CASCADE;
DROP TABLE IF EXISTS public.orders CASCADE;

-- Recreate products table with explicit foreign key
CREATE TABLE public.products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  compare_price DECIMAL(10,2),
  category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE CASCADE,
  image_url TEXT,
  images TEXT[],
  stock_quantity INTEGER DEFAULT 0,
  is_featured BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  rating DECIMAL(3,2) DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create orders table
CREATE TABLE public.orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
  total_amount DECIMAL(10,2) NOT NULL,
  shipping_address JSONB,
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
  payment_method TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recreate dependent tables
CREATE TABLE public.cart_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

CREATE TABLE public.order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id),
  quantity INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

CREATE TABLE public.wishlist (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Create indexes
CREATE INDEX idx_products_category_id ON public.products(category_id);
CREATE INDEX idx_products_is_active ON public.products(is_active);
CREATE INDEX idx_products_is_featured ON public.products(is_featured);
CREATE INDEX idx_products_slug ON public.products(slug);
CREATE INDEX idx_cart_items_user_id ON public.cart_items(user_id);
CREATE INDEX idx_orders_user_id ON public.orders(user_id);

-- Enable RLS
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlist ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Products are viewable by everyone" ON public.products FOR SELECT USING (is_active = true);
CREATE POLICY "Only admins can manage products" ON public.products FOR ALL USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Users can view own cart items" ON public.cart_items FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own cart items" ON public.cart_items FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own orders" ON public.orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own orders" ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins can view all orders" ON public.orders FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Users can view own order items" ON public.order_items FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.orders WHERE id = order_id AND user_id = auth.uid())
);

CREATE POLICY "Reviews are viewable by everyone" ON public.reviews FOR SELECT USING (true);
CREATE POLICY "Users can manage own reviews" ON public.reviews FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own wishlist" ON public.wishlist FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own wishlist" ON public.wishlist FOR ALL USING (auth.uid() = user_id);

-- Insert sample products with images
WITH category_ids AS (
  SELECT id, slug FROM public.categories
)
INSERT INTO public.products (name, slug, description, price, compare_price, category_id, image_url, images, stock_quantity, is_featured, rating, review_count) 
VALUES
  -- Electronics
  ('iPhone 15 Pro', 'iphone-15-pro', 'Latest iPhone with advanced camera system and A17 Pro chip', 999.00, 1099.00, (SELECT id FROM category_ids WHERE slug = 'electronics'), '/images/iphone-15-pro.jpg', ARRAY['/images/iphone-15-pro.jpg', '/images/iphone-15-pro-2.jpg'], 50, true, 4.8, 124),
  ('MacBook Air M2', 'macbook-air-m2', 'Powerful laptop with M2 chip and all-day battery life', 1199.00, 1299.00, (SELECT id FROM category_ids WHERE slug = 'electronics'), '/images/macbook-air-m2.jpg', ARRAY['/images/macbook-air-m2.jpg', '/images/macbook-air-m2-2.jpg'], 30, true, 4.9, 89),
  ('Samsung Galaxy S24', 'samsung-galaxy-s24', 'Premium Android smartphone with AI features', 799.00, 899.00, (SELECT id FROM category_ids WHERE slug = 'electronics'), '/images/samsung-galaxy-s24.jpg', ARRAY['/images/samsung-galaxy-s24.jpg', '/images/samsung-galaxy-s24-2.jpg'], 75, false, 4.7, 156),
  ('Sony WH-1000XM5', 'sony-wh-1000xm5', 'Industry-leading noise canceling headphones', 399.00, 449.00, (SELECT id FROM category_ids WHERE slug = 'electronics'), '/images/sony-headphones.jpg', ARRAY['/images/sony-headphones.jpg', '/images/sony-headphones-2.jpg'], 100, true, 4.6, 203),
  
  -- Fashion
  ('Premium Cotton T-Shirt', 'premium-cotton-tshirt', 'Soft, comfortable cotton t-shirt in various colors', 29.99, 39.99, (SELECT id FROM category_ids WHERE slug = 'fashion'), '/images/cotton-tshirt.jpg', ARRAY['/images/cotton-tshirt.jpg', '/images/cotton-tshirt-2.jpg'], 200, true, 4.5, 67),
  ('Nike Air Max 270', 'nike-air-max-270', 'Comfortable running shoes with Max Air cushioning', 149.99, 179.99, (SELECT id FROM category_ids WHERE slug = 'fashion'), '/images/nike-shoes.jpg', ARRAY['/images/nike-shoes.jpg', '/images/nike-shoes-2.jpg'], 80, false, 4.4, 234),
  ('Luxury Watch', 'luxury-watch', 'Elegant timepiece with leather strap', 299.00, 399.00, (SELECT id FROM category_ids WHERE slug = 'fashion'), '/images/luxury-watch.jpg', ARRAY['/images/luxury-watch.jpg', '/images/luxury-watch-2.jpg'], 25, true, 4.7, 45),
  ('Designer Jeans', 'designer-jeans', 'Premium denim jeans with perfect fit', 89.99, 119.99, (SELECT id FROM category_ids WHERE slug = 'fashion'), '/images/designer-jeans.jpg', ARRAY['/images/designer-jeans.jpg', '/images/designer-jeans-2.jpg'], 150, false, 4.3, 78),
  
  -- Beauty & Personal Care
  ('Vitamin C Serum', 'vitamin-c-serum', 'Brightening serum with 20% Vitamin C', 24.99, 34.99, (SELECT id FROM category_ids WHERE slug = 'beauty-personal-care'), '/images/vitamin-c-serum.jpg', ARRAY['/images/vitamin-c-serum.jpg', '/images/vitamin-c-serum-2.jpg'], 300, true, 4.6, 189),
  ('Moisturizing Face Cream', 'moisturizing-face-cream', 'Hydrating cream for all skin types', 19.99, 29.99, (SELECT id FROM category_ids WHERE slug = 'beauty-personal-care'), '/images/face-cream.jpg', ARRAY['/images/face-cream.jpg', '/images/face-cream-2.jpg'], 250, false, 4.4, 156),
  ('Makeup Palette', 'makeup-palette', 'Professional eyeshadow palette with 12 shades', 39.99, 49.99, (SELECT id FROM category_ids WHERE slug = 'beauty-personal-care'), '/images/makeup-palette.jpg', ARRAY['/images/makeup-palette.jpg', '/images/makeup-palette-2.jpg'], 120, true, 4.5, 92),
  
  -- Home Appliances
  ('Coffee Maker', 'coffee-maker', 'Programmable coffee maker with thermal carafe', 79.99, 99.99, (SELECT id FROM category_ids WHERE slug = 'home-appliances'), '/images/coffee-maker.jpg', ARRAY['/images/coffee-maker.jpg', '/images/coffee-maker-2.jpg'], 60, false, 4.3, 134),
  ('Air Fryer', 'air-fryer', 'Healthy cooking with little to no oil', 129.99, 159.99, (SELECT id FROM category_ids WHERE slug = 'home-appliances'), '/images/air-fryer.jpg', ARRAY['/images/air-fryer.jpg', '/images/air-fryer-2.jpg'], 45, true, 4.7, 267),
  ('Robot Vacuum', 'robot-vacuum', 'Smart vacuum cleaner with app control', 299.99, 399.99, (SELECT id FROM category_ids WHERE slug = 'home-appliances'), '/images/robot-vacuum.jpg', ARRAY['/images/robot-vacuum.jpg', '/images/robot-vacuum-2.jpg'], 35, true, 4.5, 178),
  
  -- Books & Stationery
  ('Productivity Planner', 'productivity-planner', 'Daily planner to boost productivity and organization', 24.99, 34.99, (SELECT id FROM category_ids WHERE slug = 'books-stationery'), '/images/productivity-planner.jpg', ARRAY['/images/productivity-planner.jpg', '/images/productivity-planner-2.jpg'], 200, false, 4.4, 89),
  ('Premium Notebook Set', 'premium-notebook-set', 'Set of 3 high-quality notebooks for writing', 19.99, 29.99, (SELECT id FROM category_ids WHERE slug = 'books-stationery'), '/images/notebook-set.jpg', ARRAY['/images/notebook-set.jpg', '/images/notebook-set-2.jpg'], 150, false, 4.2, 56),
  ('Best Seller Novel', 'best-seller-novel', 'Award-winning fiction novel', 14.99, 19.99, (SELECT id FROM category_ids WHERE slug = 'books-stationery'), '/images/novel-book.jpg', ARRAY['/images/novel-book.jpg', '/images/novel-book-2.jpg'], 300, true, 4.8, 1234);

-- Update categories with images
UPDATE public.categories SET image_url = '/images/categories/electronics.jpg' WHERE slug = 'electronics';
UPDATE public.categories SET image_url = '/images/categories/fashion.jpg' WHERE slug = 'fashion';
UPDATE public.categories SET image_url = '/images/categories/beauty.jpg' WHERE slug = 'beauty-personal-care';
UPDATE public.categories SET image_url = '/images/categories/home-appliances.jpg' WHERE slug = 'home-appliances';
UPDATE public.categories SET image_url = '/images/categories/books.jpg' WHERE slug = 'books-stationery';
