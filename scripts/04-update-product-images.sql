-- Update products with real images
UPDATE public.products SET 
  image_url = '/images/iphone-15-pro.jpg',
  images = ARRAY['/images/iphone-15-pro.jpg', '/images/iphone-15-pro-2.jpg']
WHERE slug = 'iphone-15-pro';

UPDATE public.products SET 
  image_url = '/images/macbook-air-m2.jpg',
  images = ARRAY['/images/macbook-air-m2.jpg', '/images/macbook-air-m2-2.jpg']
WHERE slug = 'macbook-air-m2';

UPDATE public.products SET 
  image_url = '/images/samsung-galaxy-s24.jpg',
  images = ARRAY['/images/samsung-galaxy-s24.jpg', '/images/samsung-galaxy-s24-2.jpg']
WHERE slug = 'samsung-galaxy-s24';

UPDATE public.products SET 
  image_url = '/images/sony-headphones.jpg',
  images = ARRAY['/images/sony-headphones.jpg', '/images/sony-headphones-2.jpg']
WHERE slug = 'sony-wh-1000xm5';

UPDATE public.products SET 
  image_url = '/images/cotton-tshirt.jpg',
  images = ARRAY['/images/cotton-tshirt.jpg', '/images/cotton-tshirt-2.jpg']
WHERE slug = 'premium-cotton-tshirt';

UPDATE public.products SET 
  image_url = '/images/nike-shoes.jpg',
  images = ARRAY['/images/nike-shoes.jpg', '/images/nike-shoes-2.jpg']
WHERE slug = 'nike-air-max-270';

UPDATE public.products SET 
  image_url = '/images/luxury-watch.jpg',
  images = ARRAY['/images/luxury-watch.jpg', '/images/luxury-watch-2.jpg']
WHERE slug = 'luxury-watch';

UPDATE public.products SET 
  image_url = '/images/designer-jeans.jpg',
  images = ARRAY['/images/designer-jeans.jpg', '/images/designer-jeans-2.jpg']
WHERE slug = 'designer-jeans';

UPDATE public.products SET 
  image_url = '/images/vitamin-c-serum.jpg',
  images = ARRAY['/images/vitamin-c-serum.jpg', '/images/vitamin-c-serum-2.jpg']
WHERE slug = 'vitamin-c-serum';

UPDATE public.products SET 
  image_url = '/images/face-cream.jpg',
  images = ARRAY['/images/face-cream.jpg', '/images/face-cream-2.jpg']
WHERE slug = 'moisturizing-face-cream';

UPDATE public.products SET 
  image_url = '/images/makeup-palette.jpg',
  images = ARRAY['/images/makeup-palette.jpg', '/images/makeup-palette-2.jpg']
WHERE slug = 'makeup-palette';

UPDATE public.products SET 
  image_url = '/images/coffee-maker.jpg',
  images = ARRAY['/images/coffee-maker.jpg', '/images/coffee-maker-2.jpg']
WHERE slug = 'coffee-maker';

UPDATE public.products SET 
  image_url = '/images/air-fryer.jpg',
  images = ARRAY['/images/air-fryer.jpg', '/images/air-fryer-2.jpg']
WHERE slug = 'air-fryer';

UPDATE public.products SET 
  image_url = '/images/robot-vacuum.jpg',
  images = ARRAY['/images/robot-vacuum.jpg', '/images/robot-vacuum-2.jpg']
WHERE slug = 'robot-vacuum';

UPDATE public.products SET 
  image_url = '/images/productivity-planner.jpg',
  images = ARRAY['/images/productivity-planner.jpg', '/images/productivity-planner-2.jpg']
WHERE slug = 'productivity-planner';

UPDATE public.products SET 
  image_url = '/images/notebook-set.jpg',
  images = ARRAY['/images/notebook-set.jpg', '/images/notebook-set-2.jpg']
WHERE slug = 'premium-notebook-set';

UPDATE public.products SET 
  image_url = '/images/novel-book.jpg',
  images = ARRAY['/images/novel-book.jpg', '/images/novel-book-2.jpg']
WHERE slug = 'best-seller-novel';

-- Update categories with real images
UPDATE public.categories SET image_url = '/images/categories/electronics.jpg' WHERE slug = 'electronics';
UPDATE public.categories SET image_url = '/images/categories/fashion.jpg' WHERE slug = 'fashion';
UPDATE public.categories SET image_url = '/images/categories/beauty.jpg' WHERE slug = 'beauty-personal-care';
UPDATE public.categories SET image_url = '/images/categories/home-appliances.jpg' WHERE slug = 'home-appliances';
UPDATE public.categories SET image_url = '/images/categories/books.jpg' WHERE slug = 'books-stationery';
