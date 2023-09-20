# Домашнее задание к занятию "`Основы Terraform. Yandex Cloud`" - `Никулин Михаил Сергеевич`



---

### Задание 1

В качестве ответа всегда полностью прикладывайте ваш terraform-код в git.

1. Изучите проект. В файле variables.tf объявлены переменные для Yandex provider.
2. Переименуйте файл personal.auto.tfvars_example в personal.auto.tfvars. Заполните переменные: идентификаторы облака, токен доступа. Благодаря .gitignore этот файл не попадёт в публичный репозиторий. Вы можете выбрать иной способ безопасно передать секретные данные в terraform.
3. Сгенерируйте или используйте свой текущий ssh-ключ. Запишите его открытую часть в переменную vms_ssh_root_key.
4. Инициализируйте проект, выполните код. Исправьте намеренно допущенные синтаксические ошибки. Ищите внимательно, посимвольно. Ответьте, в чём заключается их суть.
5. Ответьте, как в процессе обучения могут пригодиться параметры preemptible = true и core_fraction=5 в параметрах ВМ. Ответ в документации Yandex Cloud.

В качестве решения приложите:

* скриншот ЛК Yandex Cloud с созданной ВМ;
* скриншот успешного подключения к консоли ВМ через ssh. К OS ubuntu необходимо подключаться под пользователем ubuntu: "ssh ubuntu@vm_ip_address";
* ответы на вопросы.

### Ответы:

4. 
```
resource "yandex_compute_instance" "platform" {
  name        = "netology-develop-platform-web"
  platform_id = "standart-v4"
  resources {
    cores         = 1
    memory        = 1
    core_fraction = 5
  }
``` 
Ошибка синтаксиса, должно быть ```standard```, при этом максимальная версия из документации подразумевает ```v3```, но с параметрами производительности 5% доступны платформы Intel Broadwell (standard-v1) и Intel Cascade Lake (standard-v2). Также минимальное количество ядер может быть 2  
5. 
```preemptible = true``` - определяет прерываемость ВМ. Это виртуальные машины, которые могут быть принудительно остановлены в любой момент

```core_fraction=5``` - определяет производительность в %. Этот уровень определяет долю вычислительного времени физических ядер, которую гарантирует vCPU.

Для целей обучения это полезно, т.к. позволяет снизить цену создаваемых ВМ.

![task_1_1.png](img%2Ftask_1_1.png)
![task_1_2.png](img%2Ftask_1_2.png)


---

### Задание 2

1. Изучите файлы проекта.
2. Замените все хардкод-значения для ресурсов yandex_compute_image и yandex_compute_instance на отдельные переменные. К названиям переменных ВМ добавьте в начало префикс vm_web_ . Пример: vm_web_name.
3. Объявите нужные переменные в файле variables.tf, обязательно указывайте тип переменной. Заполните их default прежними значениями из main.tf.
4. Проверьте terraform plan. Изменений быть не должно.

### Ответы:
Изменим main.tf:
```
data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_family
}
resource "yandex_compute_instance" "platform" {
  name        = var.vm_web_name
  platform_id = var.vm_web_platform_id
  resources {
    cores         = var.vm_web_cores
    memory        = var.vm_web_memory
    core_fraction = var.vm_web_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}
```
Добавим новые переменные в variables.tf:
```
variable "vm_web_family" {
  type = string
  default = "ubuntu-2004-lts"
}

variable "vm_web_name" {
  type = string
  default = "netology-develop-platform-web"
}

variable "vm_web_platform_id" {
  type = string
  default = "standard-v1"
}

variable "vm_web_cores" {
  type = number
  default = 2
}

variable "vm_web_memory" {
  type = number
  default = 1
}

variable "vm_web_core_fraction" {
  type = number
  default = 5
}
```
Выполним ```terraform plan```
![task_2_1.png](img%2Ftask_2_1.png)

---

### Задание 3

1. Создайте в корне проекта файл 'vms_platform.tf'. Перенесите в него все переменные первой ВМ.
2. Скопируйте блок ресурса и создайте с его помощью вторую ВМ в файле main.tf: "netology-develop-platform-db" , cores = 2, memory = 2, core_fraction = 20. Объявите её переменные с префиксом vm_db_ в том же файле ('vms_platform.tf').
3. Примените изменения.

### Ответы:

Создадим новый файл ```vms_platform.tf```, в который перенесем переменные ВМ из файла ```variables.tf```, а так же объявим переменные для новой ВМ:
```
variable "vm_web_family" {
  type = string
  default = "ubuntu-2004-lts"
}

variable "vm_web_name" {
  type = string
  default = "netology-develop-platform-web"
}

variable "vm_web_platform_id" {
  type = string
  default = "standard-v1"
}

variable "vm_web_cores" {
  type = number
  default = 2
}

variable "vm_web_memory" {
  type = number
  default = 1
}

variable "vm_web_core_fraction" {
  type = number
  default = 5
}

variable "vm_db_name" {
  type = string
  default = "netology-develop-platform-db"
}

variable "vm_db_platform_id" {
  type = string
  default = "standard-v1"
}

variable "vm_db_cores" {
  type = number
  default = 2
}

variable "vm_db_memory" {
  type = number
  default = 2
}

variable "vm_db_core_fraction" {
  type = number
  default = 20
}
```
Скопируем ресурс для создания еще одной ВМ в файле ```main.tf``` и подставим объявленные переменные:
```
resource "yandex_compute_instance" "platform_2" {
  name        = var.vm_db_name
  platform_id = var.vm_db_platform_id
  resources {
    cores         = var.vm_db_cores
    memory        = var.vm_db_memory
    core_fraction = var.vm_db_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}
```
Выполним команду ```terraform plan```:
```
PS D:\Книги\DevOps\GitHub\ter-homeworks\02\src> terraform plan
data.yandex_compute_image.ubuntu: Reading...
yandex_vpc_network.develop: Refreshing state... [id=enprch5ul30gtu4chdid]
yandex_vpc_subnet.develop: Refreshing state... [id=e9bn0djtt3qjm7fr7q2o]
data.yandex_compute_image.ubuntu: Read complete after 1s [id=fd8dfofgv8k45mqv25nq]
yandex_compute_instance.platform: Refreshing state... [id=fhm944hvt8sfr73ajef3]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.platform_2 will be created
  + resource "yandex_compute_instance" "platform_2" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "serial-port-enable" = "1"
          + "ssh-keys"           = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2kpc8hkCtD5uVQdw0wUeGlNp/rKarSrCKoifhuRtCF shakal@Razer"
        }
      + name                      = "netology-develop-platform-db"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8dfofgv8k45mqv25nq"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = "e9bn0djtt3qjm7fr7q2o"
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
Применим изменения:
![task_3_1.png](img%2Ftask_3_1.png)

---

### Задание 4

1. Объявите в файле outputs.tf output типа map, содержащий { instance_name = external_ip } для каждой из ВМ.
2. Примените изменения.
В качестве решения приложите вывод значений ip-адресов команды terraform output.

### Ответ:
Создадим новый файл ```outputs.tf``` и добавим в него данные для вывода внешнего ip адреса каждой ВМ:
```
output "vm_external_ip_address_web" {
value = yandex_compute_instance.web.network_interface[0].nat_ip_address
description = "vm external ip"
}

output "vm_external_ip_address_db" {
value = yandex_compute_instance.db.network_interface[0].nat_ip_address
description = "vm external ip"
}
```
Результат вывода команды ```terraform output```:
```
PS D:\Книги\DevOps\GitHub\ter-homeworks\02\src> terraform output      
vm_external_ip_address_db = "51.250.0.45"
vm_external_ip_address_web = "51.250.80.16"
```


---
## Дополнительные задания (со звездочкой*)


### Задание 5

`Приведите ответ в свободной форме........`

1. `Заполните здесь этапы выполнения, если требуется ....`
2. `Заполните здесь этапы выполнения, если требуется ....`
3. `Заполните здесь этапы выполнения, если требуется ....`
4. `Заполните здесь этапы выполнения, если требуется ....`
5. `Заполните здесь этапы выполнения, если требуется ....`
6. 

`При необходимости прикрепитe сюда скриншоты
![Название скриншота](ссылка на скриншот)`
