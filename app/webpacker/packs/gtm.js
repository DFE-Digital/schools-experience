import Gtm from '../gtm'

const gtmData = document.querySelector('[data-gtm-id]')?.dataset

if (gtmData != null) {
  const { gtmId, gtmNonce, gtmEnabled} = gtmData

  if (gtmEnabled == 'true') {
    const gtm = new Gtm(gtmId, gtmNonce)

    gtm.init()
  }
}
