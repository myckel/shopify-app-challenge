// src/components/ProductList.jsx
import React, { useEffect, useState } from 'react'
import { LegacyCard, Layout, TextContainer } from '@shopify/polaris'
import { useAuthenticatedFetch } from '../hooks'

const ProductList = () => {
  const [products, setProducts] = useState([])
  const fetch = useAuthenticatedFetch()

  useEffect(() => {
    const fetchProducts = async () => {
      const response = await fetch('/api/products')
      const data = await response.json()

      setProducts(data)
    }

    fetchProducts()
  }, [fetch])

  return (
    <Layout>
      {products.map((product) => (
        <Layout.Section key={product.id}>
          <LegacyCard title={product.title}>
            <LegacyCard.Section>
              <TextContainer>
                <p>{product.body_html}</p>
              </TextContainer>
            </LegacyCard.Section>
          </LegacyCard>
        </Layout.Section>
      ))}
    </Layout>
  )
}

export default ProductList
