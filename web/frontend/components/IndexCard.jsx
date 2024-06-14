import React from 'react'
import { Card, TextContainer, Page, Layout } from '@shopify/polaris'
import { useNavigate } from 'react-router-dom'

const IndexCard = () => {
  const navigate = useNavigate()

  return (
    <Page narrowWidth>
      <Layout>
        <Layout.Section oneHalf>
          <Card
            title='Snapshots'
            sectioned
            primaryFooterAction={{
              content: 'View Snapshots',
              onAction: () => navigate('/snapshots')
            }}
          >
            <TextContainer>
              <p>
                View and manage your snapshots. You can restore your store to a
                previous state using snapshots.
              </p>
            </TextContainer>
          </Card>
        </Layout.Section>
        <Layout.Section oneHalf>
          <Card
            title='Create Snapshot'
            sectioned
            primaryFooterAction={{
              content: 'Create Snapshot',
              onAction: () => navigate('/createsnapshot')
            }}
          >
            <TextContainer>
              <p>
                Create a new snapshot of your store's current state. This allows
                you to restore your store to this exact state in the future.
              </p>
            </TextContainer>
          </Card>
        </Layout.Section>
        <Layout.Section oneHalf>
          <Card
            title='Local Products'
            sectioned
            primaryFooterAction={{
              content: 'Local Products',
              onAction: () => navigate('/products')
            }}
          >
            <TextContainer>
              <p>
                List of products that are stored locally. These products are not
                synced with your Shopify store. Is a backup of your products on
                your Shopify store.
              </p>
            </TextContainer>
          </Card>
        </Layout.Section>
      </Layout>
    </Page>
  )
}

export default IndexCard
