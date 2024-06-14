// src/pages/ProductsPage.jsx
import React from 'react'
import { Page, Layout } from '@shopify/polaris'
import ProductList from '../components/ProductList'

const Products = () => {
  return (
    <Page title='Products'>
      <Layout>
        <Layout.Section>
          <ProductList />
        </Layout.Section>
      </Layout>
    </Page>
  )
}

export default Products
