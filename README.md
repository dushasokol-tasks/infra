Terraform 1
###
Домашнее задание
-----------------
1,2,3,4 
================
`main.tf`:
```
user = "${var.app_user}"
```
`main.tf`:
```
variable app_user {
 default = "appuser"
}

 variable zone {
 description = "Zone"
 default     = "europe-west3-c"
}
```
*
================
```
resource "google_compute_project_metadata_item" "app" {
 key   = "ssh-keys"
 value = "${chomp(file(var.public_key_path))}\n......"
}
```
При заливке ключей на сервер, терраформ затирает предыдущие ключи

**
================
На картинке `https-load-balancer-diagram.svg` показана структура штатного балансера от гугла.
`Двигаемся справа налево, создаем группу инстансов, у нас она будет единственная, цепляем туда наши инстансы`:
```
resource "google_compute_instance_group" "igroup-reddit-app" {
  name        = "igroup-reddit-app"
  description = "Reddit app instance group"

  instances = [
        "${google_compute_instance.app.*.self_link}"
  ]

  named_port {
    name = "http"
    port = "9292"
  }

  zone = "${var.zone}"
}
```

`Это встроенный гугловский хэртбит, создаем его сущность`
```
resource "google_compute_http_health_check" "reddit-http-basic-check" {
  name         = "reddit-http-basic-check"
  request_path = ""
  port         = 9292
}
```
`Бэкэнд сервис отвечает за определенный функционал ресурса и задает правила распределения запросов, проверки самочувствия.`
```
resource "google_compute_backend_service" "bs-reddit-app" {
  name        = "bs-reddit-app"
  description = "Backend service for reddit-app"
  port_name   = "http"
  protocol    = "HTTP"
  enable_cdn  = false

  backend {
    group           = "${google_compute_instance_group.igroup-reddit-app.self_link}"
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8
  }

  health_checks = ["${google_compute_http_health_check.reddit-http-basic-check.self_link}"]
}
```
`Фильтрация в URL, для распасовки по бэкэнд сервисам`
```
resource "google_compute_url_map" "urlmap-reddit-app" {
  name        = "urlmap-reddit-app"
  description = "URL-map to redirect traffic to the backend service"

  default_service = "${google_compute_backend_service.bs-reddit-app.self_link}"
}
```
`Сущность прокси`
```
resource "google_compute_target_http_proxy" "http-lb-proxy-reddit-app" {
  name        = "http-lb-proxy-reddit-app"
  description = "Target HTTP proxy"
  url_map     = "${google_compute_url_map.urlmap-reddit-app.self_link}"
}
```
`Вешаем на проксю правило файрвола`
```
resource "google_compute_global_forwarding_rule" "frule-reddit-app" {
  name        = "website-forwarding-rule"
  description = "Forwarding rule"
  target      = "${google_compute_target_http_proxy.http-lb-proxy-reddit-app.self_link}"
  port_range  = "80"
}
```
