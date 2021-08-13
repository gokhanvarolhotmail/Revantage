requests
| project-keep *
| where timestamp > ago(60d)
| where cloud_RoleName =~ 'Membership360-AZFunc-DacadooAPI-prod'
| order by timestamp desc


traces
| project-keep *
| where timestamp > ago(60d)
| where cloud_RoleName =~ 'Membership360-AZFunc-DacadooAPI-prod'
| order by timestamp desc
