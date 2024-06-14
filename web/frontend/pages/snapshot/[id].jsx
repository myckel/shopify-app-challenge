import React from 'react'
import { useParams } from 'react-router-dom'
import { Page } from '@shopify/polaris'
import EditSnapshotForm from '../../components/EditSnapshotForm'

const EditSnapshot = () => {
  const { id } = useParams()

  return (
    <Page title='Edit Snapshot'>
      <EditSnapshotForm snapshotId={id} />
    </Page>
  )
}

export default EditSnapshot
