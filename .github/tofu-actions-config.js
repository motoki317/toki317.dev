const config = {
  tfBinary: 'terraform',
  auth: {
    mode: 'gcp-oidc',
    gcpProject: 'hobby-256508',
    gcpIdentityProvider: 'projects/905974313870/locations/global/workloadIdentityPools/github-actions-pool/providers/github-provider',
  }
}

const awsConfig = {
  tfBinary: 'terraform',
  auth: {
    mode: 'aws-oidc',
    awsRegion: 'ap-northeast-1',
    awsPlanRole: 'arn:aws:iam::673433572095:role/tofu-plan',
    awsApplyRole: 'arn:aws:iam::673433572095:role/tofu-apply',
  }
}

export default {
  dirs: {
    'tf': config,
    'tf/aws': awsConfig,
  }
}
