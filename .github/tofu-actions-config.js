const config = {
  tfBinary: 'terraform',
  auth: {
    mode: 'gcp-oidc',
    gcpProject: 'hobby-256508',
    gcpIdentityProvider: 'projects/905974313870/locations/global/workloadIdentityPools/github-actions-pool/providers/github-provider',
  }
}

export default {
  dirs: {
    'tf': config,
  }
}
