import React, { useEffect, useState } from 'react'
import {
  LegacyCard,
  Layout,
  Page,
  Button,
  Toast,
  Frame,
  Checkbox
} from '@shopify/polaris'
import { useAuthenticatedFetch } from '../hooks'
import { useNavigate } from 'react-router-dom'
import '../assets/restoreStyle.css'

const RestoreSnapshot = ({ snapshotId }) => {
  const [snapshot, setSnapshot] = useState(null)
  const [selectedProducts, setSelectedProducts] = useState([])
  const [selectedVariants, setSelectedVariants] = useState({})
  const [toastMessage, setToastMessage] = useState('')
  const [toastError, setToastError] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const fetch = useAuthenticatedFetch()
  const navigate = useNavigate()

  useEffect(() => {
    const fetchSnapshot = async () => {
      try {
        const response = await fetch(`/api/snapshots/${snapshotId}`)
        if (!response.ok) {
          throw new Error('Failed to fetch snapshot')
        }
        const data = await response.json()
        setSnapshot(data)
        setSelectedProducts(data.product_data.map((product) => product.id))
        const initialSelectedVariants = data.product_data.reduce(
          (acc, product) => {
            acc[product.id] = product.variants.map((variant) => variant.id)
            return acc
          },
          {}
        )
        setSelectedVariants(initialSelectedVariants)
      } catch (error) {
        setToastMessage(error.message)
        setToastError(true)
      }
    }

    fetchSnapshot()
  }, [snapshotId])

  const handleProductSelection = (productId) => {
    setSelectedProducts((prevSelected) => {
      if (prevSelected.includes(productId)) {
        const { [productId]: _, ...rest } = selectedVariants
        setSelectedVariants(rest)
        return prevSelected.filter((id) => id !== productId)
      } else {
        const newSelectedVariants = {
          ...selectedVariants,
          [productId]: snapshot.product_data
            .find((product) => product.id === productId)
            .variants.map((variant) => variant.id)
        }
        setSelectedVariants(newSelectedVariants)
        return [...prevSelected, productId]
      }
    })
  }

  const handleVariantSelection = (productId, variantId) => {
    setSelectedVariants((prevSelected) => {
      const productVariants = prevSelected[productId] || []
      if (productVariants.includes(variantId)) {
        const newVariants = productVariants.filter((id) => id !== variantId)
        const newSelected = { ...prevSelected, [productId]: newVariants }
        if (newVariants.length === 0) {
          setSelectedProducts((prevProducts) =>
            prevProducts.filter((id) => id !== productId)
          )
        }
        return newSelected
      } else {
        setSelectedProducts((prevProducts) =>
          prevProducts.includes(productId)
            ? prevProducts
            : [...prevProducts, productId]
        )
        return { ...prevSelected, [productId]: [...productVariants, variantId] }
      }
    })
  }

  const handleRestore = async () => {
    if (Object.keys(selectedVariants).length === 0) {
      setToastMessage('No variants selected for restoration')
      setToastError(true)
      return
    }

    try {
      setIsSubmitting(true)
      const response = await fetch(`/api/snapshots/${snapshotId}/restore`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ product_variants: selectedVariants })
      })

      if (response.ok) {
        setToastMessage('Snapshot restored successfully')
        setToastError(false)
        navigate('/snapshots')
      } else {
        throw new Error('Failed to restore snapshot')
      }
    } catch (error) {
      setToastMessage(error.message)
      setToastError(true)
    } finally {
      setIsSubmitting(false)
    }
  }

  const selectAllProducts = () => {
    setSelectedProducts(snapshot.product_data.map((product) => product.id))
    const allSelectedVariants = snapshot.product_data.reduce((acc, product) => {
      acc[product.id] = product.variants.map((variant) => variant.id)
      return acc
    }, {})
    setSelectedVariants(allSelectedVariants)
  }

  const deselectAllProducts = () => {
    setSelectedProducts([])
    setSelectedVariants({})
  }

  const toastMarkup = toastMessage && (
    <Toast
      content={toastMessage}
      error={toastError}
      onDismiss={() => setToastMessage('')}
    />
  )

  if (!snapshot) {
    return <div>Loading...</div>
  }

  return (
    <Frame>
      {toastMarkup}
      <Page title={`Restore Snapshot: ${snapshot.name}`}>
        <Layout>
          <Layout.Section>
            <LegacyCard sectioned>
              <p>
                Created at: {new Date(snapshot.created_at).toLocaleString()}
              </p>
            </LegacyCard>
            <LegacyCard sectioned>
              <p>Select products to restore:</p>
              <div className='button-group'>
                <Button primary onClick={selectAllProducts}>
                  Select All
                </Button>
                <Button primary onClick={deselectAllProducts}>
                  Deselect All
                </Button>
              </div>
              {snapshot.product_data.map((product) => (
                <div key={product.id}>
                  <Checkbox
                    label={product.title}
                    checked={selectedProducts.includes(product.id)}
                    onChange={() => handleProductSelection(product.id)}
                  />
                  {product.variants && product.variants.length > 0 && (
                    <div style={{ marginLeft: '20px' }}>
                      {product.variants.map((variant) => (
                        <div key={variant.id}>
                          <Checkbox
                            label={variant.title}
                            checked={selectedVariants[product.id]?.includes(
                              variant.id
                            )}
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
            </LegacyCard>
            <LegacyCard sectioned>
              <div className='button-group'>
                <Button primary onClick={handleRestore} disabled={isSubmitting}>
                  Restore Selected Products
                </Button>
                <Button destructive onClick={() => navigate('/snapshots')}>
                  Cancel
                </Button>
              </div>
            </LegacyCard>
          </Layout.Section>
        </Layout>
      </Page>
    </Frame>
  )
}

export default RestoreSnapshot
