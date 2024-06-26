import { BrowserRouter } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { NavigationMenu } from '@shopify/app-bridge-react'
import Routes from './Routes'
import { AppBridgeProvider, QueryProvider, PolarisProvider } from './components'

export default function App() {
  const pages = import.meta.globEager('./pages/**/!(*.test.[jt]sx)*.([jt]sx)')
  const { t } = useTranslation()

  return (
    <PolarisProvider>
      <BrowserRouter>
        <AppBridgeProvider>
          <QueryProvider>
            <NavigationMenu
              navigationLinks={[
                {
                  label: 'Create Snapshot',
                  destination: '/createsnapshot'
                },
                {
                  label: 'Snapshots',
                  destination: '/snapshots'
                },
                {
                  label: 'Local Products',
                  destination: '/products'
                }
              ]}
            />
            <Routes pages={pages} />
          </QueryProvider>
        </AppBridgeProvider>
      </BrowserRouter>
    </PolarisProvider>
  )
}
