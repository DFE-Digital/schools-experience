import Gtm from '../gtm'

const { gtmId, gtmNonce } = document.querySelector('[data-gtm-id]').dataset
const gtm = new Gtm(gtmId, gtmNonce)

gtm.init()
