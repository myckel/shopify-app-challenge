import React from 'react'
import { useParams } from 'react-router-dom'
import { Page } from '@shopify/polaris'
import RestoreSnapshot from '../../components/RestoreSnapshot'

const EditSnapshot = () => {
  const { id } = useParams()

  return (
    <Page>
      <RestoreSnapshot snapshotId={id} />
    </Page>
  )
}

export default EditSnapshot
