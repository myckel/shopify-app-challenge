import React, { useEffect, useState } from 'react'
import {
  Card,
  ResourceList,
  ResourceItem,
  TextStyle,
  Thumbnail
} from '@shopify/polaris'

const ProductList = () => {
  const [products, setProducts] = useState([])

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const response = await fetch('/api/products/local')
        const data = await response.json()
        setProducts(data)
      } catch (error) {
        console.error('Error fetching products:', error)
      }
    }

    fetchProducts()
  }, [])

  return (
    <Card>
      <ResourceList
        resourceName={{ singular: 'product', plural: 'products' }}
        items={products}
        renderItem={(item) => {
          const { id, title, image, price, variants } = item
          const media = image ? (
            <Thumbnail source={`data:image/jpeg;base64,${image}`} alt={title} />
          ) : (
            <Thumbnail source='' alt='No image available' />
          )
          return (
            <ResourceItem
              id={id}
              media={media}
              accessibilityLabel={`View details for ${title}`}
            >
              <h3>
                <TextStyle variation='strong'>{title}</TextStyle>
              </h3>
              <div>Price: {price}</div>
              <div>Variants:</div>
              <ul>
                {variants.map((variant) => (
                  <li key={variant.id}>
                    Title:{variant.title} - Price: {variant.price}
                    Inventory: {variant.inventory_quantity}
                  </li>
                ))}
              </ul>
            </ResourceItem>
          )
        }}
      />
    </Card>
  )
}

export default ProductList
