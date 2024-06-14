// src/pages/snapshots.jsx
import React from 'react'
import { Page, Layout } from '@shopify/polaris'
import SnapshotList from '../components/SnapshotList'

const Snapshots = () => (
  <Page title='Snapshots'>
    <Layout>
      <Layout.Section>
        <SnapshotList />
      </Layout.Section>
    </Layout>
  </Page>
)

export default Snapshots
