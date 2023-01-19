resource "chronosphere_monitor" "mon_chronoprom_memory_utilization_hi" {
  name                   = "Chronoprom Memory Utilization High"
  slug                   = "mon-chronoprom-memory-utilization-hi"
  bucket_id              = "chronoprom_alerts"
  notification_policy_id = "chronoprom_alerts"

  labels = {
    "team" = "platform"
  }

  annotations = {
    "description" = "Chronoprom memory usage is at {{ printf \"%.2f\" $value }}% of its limit which can lead to OOM and metrics loss."
    "grafana"     = "https://meta.chronosphere.io/dashboards/d/67pfEf2Zk/kubelet-cadvisor?refresh=5m&var-cluster={{ $labels.chronosphere_k8s_cluster }}&var-node={{ $labels.instance }}&var-interval=$__auto_interval_interval&var-pod={{ $labels.container }}"
    "logs"        = "https://console.cloud.google.com/logs/query;query=resource.labels.cluster_name%3D%22{{ .Labels.chronosphere_k8s_cluster }}%22%0Aresource.labels.namespace_name%3D%22{{ .Labels.chronosphere_k8s_namespace }}%22%0Aresource.labels.container_name%3D%22prom%22;storageScope=storage%2Cprojects%2Fchronosphere-monitoring%2Flocations%2Fglobal%2Fbuckets%2Faggregated-logs%2Fviews%2F_AllLogs?project=chronosphere-monitoring"
    "runbook"     = "http://go/chronoprom-memory-utilization-is-high"
  }

  query {
    prometheus_expr = "(container_memory_usage_bytes{container=\"prom\",name=~\".+\"} / (container_spec_memory_limit_bytes{container=\"prom\",name=~\".+\"} > 0)) * 100"
  }

  signal_grouping {
    label_names = ["chronosphere_k8s_cluster", "namespace"]
  }

  series_conditions {
    condition {
      severity = "critical"
      value    = 50
      op       = "GT"
      sustain  = "180s"
    }

    condition {
      severity = "warn"
      value    = 60
      op       = "GT"
      sustain  = "180s"
    }
  }

  interval = "30s"
}

