import './../assets/formStyle.css'
import React, { useState, useEffect, useCallback, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  AlphaCard,
  Layout,
  TextField,
  Button,
  Toast,
  Frame,
  Checkbox
} from '@shopify/polaris'
import { useAuthenticatedFetch } from '../hooks'

const EditSnapshotForm = ({ snapshotId }) => {
  const [snapshot, setSnapshot] = useState(null)
  const [snapshotName, setSnapshotName] = useState('')
  const [createdAt, setCreatedAt] = useState('')
  const [products, setProducts] = useState([])
  const [selectedProducts, setSelectedProducts] = useState([])
  const [toastMessage, setToastMessage] = useState('')
  const [toastError, setToastError] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const fetch = useAuthenticatedFetch()
  const navigate = useNavigate()

  const initialFetchRef = useRef(true)

  useEffect(() => {
    if (initialFetchRef.current) {
      initialFetchRef.current = false

      const fetchSnapshotAndProducts = async () => {
        const [snapshotResponse, productsResponse] = await Promise.all([
          fetch(`/api/snapshots/${snapshotId}`),
          fetch('/api/products')
        ])

        const snapshotData = await snapshotResponse.json()
        const productsData = await productsResponse.json()

        setSnapshot(snapshotData)
        setSnapshotName(snapshotData.name)
        setCreatedAt(formatDate(snapshotData.created_at))

        const selectedProductIds = snapshotData.product_data.flatMap(
          (product) => [
            product.id?.toString() || '',
            ...product.variants.map((variant) => variant.id?.toString() || '')
          ]
        )
        setSelectedProducts(selectedProductIds)

        const mergedProducts = productsData.map((product) => {
          const snapshotProduct = snapshotData.product_data.find(
            (sp) => sp.id === product.id
          )
          return {
            ...product,
            variants: product.variants.map((variant) => {
              const snapshotVariant = snapshotProduct?.variants.find(
                (sv) => sv.id === variant.id
              )
              return {
                ...variant,
                inventory:
                  snapshotVariant?.inventory ?? variant.inventory_quantity,
                status: snapshotProduct?.status || product.status
              }
            }),
            status: snapshotProduct?.status || product.status,
            snapshotData: snapshotProduct
          }
        })
        setProducts(mergedProducts)
      }

      fetchSnapshotAndProducts()
    }
  }, [fetch, snapshotId])

  const handleSnapshotNameChange = useCallback(
    (value) => setSnapshotName(value),
    []
  )

  const handleCreatedAtChange = useCallback((value) => setCreatedAt(value), [])

  const handleProductSelection = useCallback(
    (productId, isVariant = false) => {
      setSelectedProducts((prevSelected) => {
        const newSelected = new Set(prevSelected)

        if (isVariant) {
          const product = products.find((p) =>
            p.variants.some((v) => v.id.toString() === productId.toString())
          )

          if (newSelected.has(productId)) {
            newSelected.delete(productId)
          } else {
            newSelected.add(productId)
            if (product) {
              newSelected.add(product.id.toString())
            }
          }

          const anyVariantsSelected = product?.variants.some((v) =>
            newSelected.has(v.id.toString())
          )
          if (!anyVariantsSelected) {
            newSelected.delete(product?.id.toString())
          }
        } else {
          const product = products.find(
            (p) => p.id.toString() === productId.toString()
          )

          if (newSelected.has(productId)) {
            newSelected.delete(productId)
            product?.variants.forEach((v) =>
              newSelected.delete(v.id.toString())
            )
          } else {
            newSelected.add(productId)
            product?.variants.forEach((v) => newSelected.add(v.id.toString()))
          }
        }

        return Array.from(newSelected)
      })
    },
    [products]
  )

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

  const handleSubmit = useCallback(async () => {
    setIsSubmitting(true)
    const selectedProductData = products
      .filter((product) => selectedProducts.includes(product.id.toString()))
      .map((product) => {
        const snapshotProduct =
          snapshot.product_data.find((p) => p.id === product.id) || product
        const selectedVariants = product.variants.filter((variant) =>
          selectedProducts.includes(variant.id.toString())
        )

        // Logic to keep images if they are deleted from the store
        const updatedImages = snapshotProduct?.images || []
        const currentImages = product.images.map((image) => image.src)
        currentImages.forEach((currentImage) => {
          if (!updatedImages.includes(currentImage)) {
            updatedImages.push(currentImage)
          }
        })

        return {
          title: product.title,
          description: product.description,
          price: product.variants[0]?.price,
          id: product.id,
          type: 'Product',
          status: product.status,
          images: updatedImages,
          variants: selectedVariants.map((variant) => ({
            title: variant.title,
            price: variant.price,
            inventory: variant.inventory,
            inventory_item_id: variant.inventory_item_id,
            sku: variant.sku,
            id: variant.id,
            type: 'Variant'
          }))
        }
      })

    const response = await fetch(`/api/snapshots/${snapshotId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        name: snapshotName,
        created_at: createdAt,
        product_data: selectedProductData
      })
    })

    if (response.ok) {
      setToastMessage('Snapshot updated successfully')
      setToastError(false)
      navigate('/snapshots')
    } else {
      setToastMessage('Failed to update snapshot')
      setToastError(true)
    }
    setIsSubmitting(false)
  }, [
    snapshotName,
    createdAt,
    snapshot,
    selectedProducts,
    products,
    snapshotId,
    fetch,
    navigate
  ])

  const toastMarkup = toastMessage && (
    <Toast
      content={toastMessage}
      error={toastError}
      onDismiss={() => setToastMessage('')}
    />
  )

  const formatDate = (dateString) => {
    const date = new Date(dateString)
    return date.toISOString().slice(0, 16)
  }

  return (
    <Frame>
      {toastMarkup}
      <div className='snapshot-form-container'>
        <AlphaCard sectioned>
          <TextField
            label='Snapshot Name'
            value={snapshotName}
            onChange={handleSnapshotNameChange}
            autoComplete='off'
          />
          <TextField
            label='Created At'
            value={createdAt}
            onChange={handleCreatedAtChange}
            autoComplete='off'
            type='datetime-local'
          />
          <div className='product-checkboxes' style={{ marginTop: '20px' }}>
            {products.map((product) => {
              const productInSnapshot = snapshot?.product_data.find(
                (sp) => sp.id === product.id
              )
              const allVariants = product.variants

              return (
                <div key={product.id}>
                  <Checkbox
                    className='product-checkbox'
                    label={
                      <span>
                        {product.title}{' '}
                        <span className={getStatusClassName(product.status)}>
                          {product.status}
                        </span>
                      </span>
                    }
                    checked={selectedProducts.includes(product.id.toString())}
                    onChange={() =>
                      handleProductSelection(product.id.toString())
                    }
                  />
                  {allVariants && allVariants.length > 0 && (
                    <div className='variant-checkboxes'>
                      {allVariants.map((variant) => {
                        const snapshotVariant =
                          productInSnapshot?.variants.find(
                            (sv) => sv.id === variant.id
                          )
                        const inventory =
                          snapshotVariant?.inventory ??
                          variant.inventory_quantity

                        return (
                          <div key={variant.id}>
                            <Checkbox
                              label={`${variant.title} (Inventory: ${inventory})`}
                              checked={selectedProducts.includes(
                                variant.id.toString()
                              )}
                              onChange={() =>
                                handleProductSelection(
                                  variant.id.toString(),
                                  true
                                )
                              }
                            />
                          </div>
                        )
                      })}
                    </div>
                  )}
                </div>
              )
            })}
          </div>
          <Button onClick={handleSubmit} primary disabled={isSubmitting}>
            Save Changes
          </Button>
        </AlphaCard>
      </div>
    </Frame>
  )
}

export default EditSnapshotForm
