-- Drop and recreate the products table with proper foreign key
DROP TABLE IF EXISTS public.products CASCADE;

-- Recreate products table with explicit foreign key constraint
CREATE TABLE public.products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  compare_price DECIMAL(10,2),
  category_id UUID NOT NULL,
  image_url TEXT,
  images TEXT[],
  stock_quantity INTEGER DEFAULT 0,
  is_featured BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  rating DECIMAL(3,2) DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_products_category_id ON public.products(category_id);
CREATE INDEX idx_products_is_active ON public.products(is_active);
CREATE INDEX idx_products_is_featured ON public.products(is_featured);
CREATE INDEX idx_products_slug ON public.products(slug);

-- Enable RLS
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Recreate policies
CREATE POLICY "Products are viewable by everyone" ON public.products FOR SELECT USING (is_active = true);
CREATE POLICY "Only admins can manage products" ON public.products FOR ALL USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Re-insert sample products
WITH category_ids AS (
  SELECT id, slug FROM public.categories
)
INSERT INTO public.products (name, slug, description, price, compare_price, category_id, image_url, images, stock_quantity, is_featured, rating, review_count) 
SELECT * FROM (
  VALUES
  -- Electronics
  ('iPhone 15 Pro', 'iphone-15-pro', 'Latest iPhone with advanced camera system and A17 Pro chip', 999.00, 1099.00, (SELECT id FROM category_ids WHERE slug = 'electronics'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400', '/placeholder.svg?height=400&width=400'], 50, true, 4.8, 124),
  ('MacBook Air M2', 'macbook-air-m2', 'Powerful laptop with M2 chip and all-day battery life', 1199.00, 1299.00, (SELECT id FROM category_ids WHERE slug = 'electronics'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 30, true, 4.9, 89),
  ('Samsung Galaxy S24', 'samsung-galaxy-s24', 'Premium Android smartphone with AI features', 799.00, 899.00, (SELECT id FROM category_ids WHERE slug = 'electronics'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 75, false, 4.7, 156),
  ('Sony WH-1000XM5', 'sony-wh-1000xm5', 'Industry-leading noise canceling headphones', 399.00, 449.00, (SELECT id FROM category_ids WHERE slug = 'electronics'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 100, true, 4.6, 203),
  
  -- Fashion
  ('Premium Cotton T-Shirt', 'premium-cotton-tshirt', 'Soft, comfortable cotton t-shirt in various colors', 29.99, 39.99, (SELECT id FROM category_ids WHERE slug = 'fashion'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 200, true, 4.5, 67),
  ('Nike Air Max 270', 'nike-air-max-270', 'Comfortable running shoes with Max Air cushioning', 149.99, 179.99, (SELECT id FROM category_ids WHERE slug = 'fashion'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 80, false, 4.4, 234),
  ('Luxury Watch', 'luxury-watch', 'Elegant timepiece with leather strap', 299.00, 399.00, (SELECT id FROM category_ids WHERE slug = 'fashion'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 25, true, 4.7, 45),
  ('Designer Jeans', 'designer-jeans', 'Premium denim jeans with perfect fit', 89.99, 119.99, (SELECT id FROM category_ids WHERE slug = 'fashion'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 150, false, 4.3, 78),
  
  -- Beauty & Personal Care
  ('Vitamin C Serum', 'vitamin-c-serum', 'Brightening serum with 20% Vitamin C', 24.99, 34.99, (SELECT id FROM category_ids WHERE slug = 'beauty-personal-care'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 300, true, 4.6, 189),
  ('Moisturizing Face Cream', 'moisturizing-face-cream', 'Hydrating cream for all skin types', 19.99, 29.99, (SELECT id FROM category_ids WHERE slug = 'beauty-personal-care'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 250, false, 4.4, 156),
  ('Makeup Palette', 'makeup-palette', 'Professional eyeshadow palette with 12 shades', 39.99, 49.99, (SELECT id FROM category_ids WHERE slug = 'beauty-personal-care'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 120, true, 4.5, 92),
  
  -- Home Appliances
  ('Coffee Maker', 'coffee-maker', 'Programmable coffee maker with thermal carafe', 79.99, 99.99, (SELECT id FROM category_ids WHERE slug = 'home-appliances'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 60, false, 4.3, 134),
  ('Air Fryer', 'air-fryer', 'Healthy cooking with little to no oil', 129.99, 159.99, (SELECT id FROM category_ids WHERE slug = 'home-appliances'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 45, true, 4.7, 267),
  ('Robot Vacuum', 'robot-vacuum', 'Smart vacuum cleaner with app control', 299.99, 399.99, (SELECT id FROM category_ids WHERE slug = 'home-appliances'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 35, true, 4.5, 178),
  
  -- Books & Stationery
  ('Productivity Planner', 'productivity-planner', 'Daily planner to boost productivity and organization', 24.99, 34.99, (SELECT id FROM category_ids WHERE slug = 'books-stationery'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 200, false, 4.4, 89),
  ('Premium Notebook Set', 'premium-notebook-set', 'Set of 3 high-quality notebooks for writing', 19.99, 29.99, (SELECT id FROM category_ids WHERE slug = 'books-stationery'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 150, false, 4.2, 56),
  ('Best Seller Novel', 'best-seller-novel', 'Award-winning fiction novel', 14.99, 19.99, (SELECT id FROM category_ids WHERE slug = 'books-stationery'), '/placeholder.svg?height=400&width=400', ARRAY['/placeholder.svg?height=400&width=400'], 300, true, 4.8, 1234)
) AS products_data;
