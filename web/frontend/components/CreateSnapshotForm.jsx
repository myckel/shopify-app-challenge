import './../assets/formStyle.css'
import React, { useState, useEffect } from 'react'
import {
  LegacyCard,
  Layout,
  TextField,
  Button,
  Page,
  Toast,
  Frame,
  Checkbox,
  Spinner
} from '@shopify/polaris'
import { useAuthenticatedFetch } from '../hooks'
import { useNavigate } from 'react-router-dom'

const CreateSnapshotForm = () => {
  const [snapshotName, setSnapshotName] = useState('')
  const [products, setProducts] = useState([])
  const [selectedProducts, setSelectedProducts] = useState([])
  const [toastMessage, setToastMessage] = useState('')
  const [toastError, setToastError] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [isLoading, setIsLoading] = useState(true)
  const fetch = useAuthenticatedFetch()
  const navigate = useNavigate()

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const response = await fetch('/api/products')
        const data = await response.json()
        setProducts(data)
      } catch (error) {
        setToastMessage('Failed to load products')
        setToastError(true)
      } finally {
        setIsLoading(false)
      }
    }

    fetchProducts()
  }, [fetch])

  const handleSnapshotNameChange = (value) => setSnapshotName(value)

  const handleProductSelection = (productId, variants = []) => {
    setSelectedProducts((prevSelected) => {
      if (prevSelected.includes(productId)) {
        return prevSelected.filter(
          (id) => id !== productId && !variants.includes(id)
        )
      } else {
        return [...prevSelected, productId, ...variants]
      }
    })
  }

  const handleVariantSelection = (productId, variantId) => {
    setSelectedProducts((prevSelected) => {
      const newSelected = new Set(prevSelected)
      if (newSelected.has(variantId)) {
        newSelected.delete(variantId)
        const otherVariantsSelected = products
          .find((product) => product.id === productId)
          .variants.some((variant) => newSelected.has(variant.id))
        if (!otherVariantsSelected) {
          newSelected.delete(productId)
        }
      } else {
        newSelected.add(productId)
        newSelected.add(variantId)
      }
      return Array.from(newSelected)
    })
  }

  const getStatusClassName = (status) => {
    switch (status) {
      case 'active':
        return 'status-active'
      case 'draft':
        return 'status-draft'
      case 'archived':
        return 'status-archived'
      default:
        return ''
    }
  }

  const handleSubmit = async () => {
    if (!snapshotName) {
      setToastMessage('Snapshot name is required')
      setToastError(true)
      return
    }

    setIsSubmitting(true)
    const selectedProductData = products
      .filter(
        (product) =>
          selectedProducts.includes(product.id) ||
          product.variants.some((variant) =>
            selectedProducts.includes(variant.id)
          )
      )
      .map((product) => ({
        title: product.title,
        description: product.description,
        images: product.images.map((image) => image.src),
        price: product.variants[0]?.price,
        id: product.id,
        type: 'Product',
        status: product.status,
        variants: product.variants
          .filter((variant) => selectedProducts.includes(variant.id))
          .map((variant) => ({
            title: variant.title,
            price: variant.price,
            inventory:
              variant.inventory_quantity ??
              product.variants.reduce(
                (sum, variant) => sum + (variant.inventory_quantity || 0),
                0
              ),
            sku: variant.sku,
            inventory_item_id: variant.inventory_item_id,
            id: variant.id,
            type: 'Variant'
          }))
      }))

    const response = await fetch('/api/snapshots', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        name: snapshotName,
        product_data: selectedProductData
      })
    })

    if (response.ok) {
      setSnapshotName('')
      setSelectedProducts([])
      setToastMessage('Snapshot created successfully')
      setToastError(false)
      navigate('/snapshots')
    } else {
      setToastMessage('Failed to create snapshot')
      setToastError(true)
    }
    setIsSubmitting(false)
  }

  const toastMarkup = toastMessage && (
    <Toast
      content={toastMessage}
      error={toastError}
      onDismiss={() => setToastMessage('')}
    />
  )

  return (
    <Frame>
      {toastMarkup}
      <Page title='Create Snapshot'>
        <div className='snapshot-form-container'>
          {isLoading ? (
            <Spinner size='large' />
          ) : (
            <LegacyCard sectioned>
              <TextField
                label='Snapshot Name'
                value={snapshotName}
                onChange={handleSnapshotNameChange}
                autoComplete='off'
              />
              <div className='product-checkboxes'>
                {products.map((product) => (
                  <div key={product.id}>
                    <Checkbox
                      id={product.id.toString()}
                      label={
                        <span>
                          {product.title}{' '}
                          <span className={getStatusClassName(product.status)}>
                            {product.status}
                          </span>
                        </span>
                      }
                      checked={selectedProducts.includes(product.id)}
                      onChange={() =>
                        handleProductSelection(
                          product.id,
                          product.variants.map((variant) => variant.id)
                        )
                      }
                    />
                    {product.variants && product.variants.length > 0 && (
                      <div className='variant-checkboxes'>
                        {product.variants.map((variant) => (
                          <div key={variant.id}>
                            <Checkbox
                              id={variant.id.toString()}
                              label={variant.title}
                              checked={selectedProducts.includes(variant.id)}
                              onChange={() =>
                                handleVariantSelection(product.id, variant.id)
                              }
                            />
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                ))}
              </div>
              <Button onClick={handleSubmit} primary disabled={isSubmitting}>
                Create Snapshot
              </Button>
            </LegacyCard>
          )}
        </div>
      </Page>
    </Frame>
  )
}

export default CreateSnapshotForm
