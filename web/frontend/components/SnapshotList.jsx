import React, { useEffect, useState } from 'react'
import {
  LegacyCard,
  Layout,
  TextContainer,
  Page,
  Collapsible,
  Button,
  Toast,
  Frame
} from '@shopify/polaris'
import { useAuthenticatedFetch } from '../hooks'
import { useNavigate } from 'react-router-dom'
import '../assets/snapshotList.css'

const SnapshotList = () => {
  const [snapshots, setSnapshots] = useState([])
  const [expandedSnapshotId, setExpandedSnapshotId] = useState(null)
  const [toastMessage, setToastMessage] = useState('')
  const [toastError, setToastError] = useState(false)
  const fetch = useAuthenticatedFetch()
  const navigate = useNavigate()

  useEffect(() => {
    const fetchSnapshots = async () => {
      const response = await fetch('/api/snapshots')
      const data = await response.json()
      setSnapshots(data)
    }

    fetchSnapshots()
  }, [])

  const toggleExpand = (snapshotId) => {
    setExpandedSnapshotId((prevId) =>
      prevId === snapshotId ? null : snapshotId
    )
  }

  const handleDelete = async (snapshotId) => {
    try {
      const response = await fetch(`/api/snapshots/${snapshotId}`, {
        method: 'DELETE'
      })

      if (response.ok) {
        setSnapshots((prevSnapshots) =>
          prevSnapshots.filter((snapshot) => snapshot.id !== snapshotId)
        )
        setToastMessage('Snapshot deleted successfully')
        setToastError(false)
      } else {
        throw new Error('Failed to delete snapshot')
      }
    } catch (error) {
      setToastMessage(error.message)
      setToastError(true)
    }
  }

  const handleEdit = (snapshotId) => {
    navigate(`/snapshot/${snapshotId}`)
  }

  const handleRestore = (snapshotId) => {
    navigate(`/restore-snapshot/${snapshotId}`)
  }

  const formatDateTime = (dateString) => {
    const options = {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      hour12: true,
      timeZone: 'UTC'
    }
    const date = new Date(dateString)
    return (
      date.toLocaleString('en-GB', options).replace(',', '').toUpperCase() +
      ' UTC'
    )
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
      <Page>
        <Layout>
          {snapshots.map((snapshot) => {
            const products = snapshot.product_data
            const isExpanded = expandedSnapshotId === snapshot.id

            return (
              <Layout.Section key={snapshot.id}>
                <LegacyCard
                  title={snapshot.name}
                  actions={[
                    {
                      content: isExpanded ? 'Collapse' : 'Expand',
                      onAction: () => toggleExpand(snapshot.id)
                    }
                  ]}
                >
                  <LegacyCard.Section>
                    <TextContainer>
                      <p>Created at: {formatDateTime(snapshot.created_at)}</p>
                    </TextContainer>
                  </LegacyCard.Section>
                  <LegacyCard.Section>
                    <Collapsible
                      open={isExpanded}
                      id={`snapshot-${snapshot.id}`}
                      transition={{
                        duration: '200ms',
                        timingFunction: 'ease-in-out'
                      }}
                    >
                      <TextContainer>
                        <p>Products:</p>
                        {products.map((product, index) => (
                          <div key={index} style={{ marginBottom: '10px' }}>
                            <p>
                              <strong>Title:</strong> {product.title}
                            </p>
                            <p>
                              <strong>Description:</strong>{' '}
                              {product.description}
                            </p>
                            <p>
                              <strong>Price:</strong> {product.price}
                            </p>
                            {product.variants &&
                              product.variants.length > 0 && (
                                <div>
                                  <p>
                                    <strong>Variants:</strong>
                                  </p>
                                  {product.variants.map((variant, vIndex) => (
                                    <div
                                      key={vIndex}
                                      style={{
                                        marginLeft: '20px',
                                        marginBottom: '10px'
                                      }}
                                    >
                                      <p>
                                        <strong>Title:</strong> {variant.title}
                                      </p>
                                      <p>
                                        <strong>Price:</strong> {variant.price}
                                      </p>
                                      <p>
                                        <strong>Inventory:</strong>{' '}
                                        {variant.inventory}
                                      </p>
                                    </div>
                                  ))}
                                </div>
                              )}
                          </div>
                        ))}
                      </TextContainer>
                    </Collapsible>
                  </LegacyCard.Section>
                  <LegacyCard.Section>
                    <div className='button-group'>
                      <Button primary onClick={() => handleEdit(snapshot.id)}>
                        Edit Snapshot
                      </Button>
                      <Button
                        primary
                        onClick={() => handleRestore(snapshot.id)}
                      >
                        Restore Snapshot
                      </Button>
                      <Button
                        destructive
                        onClick={() => handleDelete(snapshot.id)}
                      >
                        Delete Snapshot
                      </Button>
                    </div>
                  </LegacyCard.Section>
                </LegacyCard>
              </Layout.Section>
            )
          })}
        </Layout>
      </Page>
    </Frame>
  )
}

export default SnapshotList
