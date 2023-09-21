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
Изменим [main.tf](src%2Fmain.tf):
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
Добавим новые переменные в [variables.tf](src%2Fvariables.tf):
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

Создадим новый файл [vms_platform.tf](src%2Fvms_platform.tf), в который перенесем переменные ВМ из файла [variables.tf](src%2Fvariables.tf), а так же объявим переменные для новой ВМ:
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
Скопируем ресурс для создания еще одной ВМ в файле [main.tf](src%2Fmain.tf) и подставим объявленные переменные:
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
Создадим новый файл [outputs.tf](src%2Foutputs.tf) и добавим в него данные для вывода внешнего ip адреса каждой ВМ:
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

### Задание 5

1. В файле locals.tf опишите в одном local-блоке имя каждой ВМ, используйте интерполяцию ${..} с несколькими переменными по примеру из лекции.
2. Замените переменные с именами ВМ из файла variables.tf на созданные вами local-переменные.
3. Примените изменения.

### Ответ:

Добавим данные в файл [locals.tf](src%2Flocals.tf) и [variables.tf](src%2Fvariables.tf):
```
locals {
  web = "${ var.name }-${ var.env }-${ var.project }-${ var.role[0] }"
  db = "${ var.name }-${ var.env }-${ var.project }-${ var.role[1] }"
}
```
```
variable "name" {
  default     = "netology"
}

variable "env" {
  default     = "develop"
}

variable "project" {
  default     = "platform"
}

variable "role" {
   default = ["web", "db"]
}
```

---

### Задание 6

1. Вместо использования трёх переменных ".._cores",".._memory",".._core_fraction" в блоке resources {...}, объедините их в переменные типа map с именами "vm_web_resources" и "vm_db_resources". В качестве продвинутой практики попробуйте создать одну map-переменную vms_resources и уже внутри неё конфиги обеих ВМ — вложенный map.
2. Также поступите с блоком metadata {serial-port-enable, ssh-keys}, эта переменная должна быть общая для всех ваших ВМ.
3. Найдите и удалите все более не используемые переменные проекта.
4. Проверьте terraform plan. Изменений быть не должно.

### Ответ:

В файл [vms_platform.tf](src%2Fvms_platform.tf) добавил переменные vms_resources и vms_metadata с конфигурациями для обеих ВМ:
```
variable "vms_resources" {
  type = map(object({
    cores = number
    memory = number
    core_fraction = number
  }))
  default = {
    vm_web_resources = {
      cores         = 2
      memory        = 1
      core_fraction = 5
    }
    vm_db_resources = {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
  }
}

variable "vms_metadata" {
  type = map
  default = {
    serial-port-enable = 1
    ssh-keys = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2kpc8hkCtD5uVQdw0wUeGlNp/rKarSrCKoifhuRtCF shakal@Razer"
  }
}
```
Отредактировал файл [main.tf](src%2Fmain.tf), внес ссылки на новые переменные:
```
resource "yandex_compute_instance" "web" {
  name        = local.web
  platform_id = var.vm_web_platform_id
  resources {
    cores         = var.vms_resources["vm_web_resources"]["cores"]
    memory        = var.vms_resources["vm_web_resources"]["memory"]
    core_fraction = var.vms_resources["vm_web_resources"]["core_fraction"]
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
    serial-port-enable = var.vms_metadata["serial-port-enable"]
    ssh-keys           = var.vms_metadata["ssh-keys"]
  }

}

resource "yandex_compute_instance" "db" {
  name        = local.db
  platform_id = var.vm_db_platform_id
  resources {
    cores         = var.vms_resources["vm_db_resources"]["cores"]
    memory        = var.vms_resources["vm_db_resources"]["memory"]
    core_fraction = var.vms_resources["vm_db_resources"]["core_fraction"]
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
    serial-port-enable = var.vms_metadata["serial-port-enable"]
    ssh-keys           = var.vms_metadata["ssh-keys"]
  }

}
```
Закоментировал неиспользуемые переменные и запустил команду ```terraform plan```, изменений не внесено:
```
PS D:\Книги\DevOps\GitHub\ter-homeworks\02\src> terraform plan
data.yandex_compute_image.ubuntu: Reading...
yandex_vpc_network.develop: Refreshing state... [id=enpt9e7o3rjp2r9eobs7]
data.yandex_compute_image.ubuntu: Read complete after 2s [id=fd8dfofgv8k45mqv25nq]
yandex_vpc_subnet.develop: Refreshing state... [id=e9b87o9f1j4gq6vhl36d]
yandex_compute_instance.db: Refreshing state... [id=fhm0acsfkhn0jhrvtf87]
yandex_compute_instance.web: Refreshing state... [id=fhmoe74jg3ahhp53g8rn]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```

---

## Дополнительные задания (со звездочкой*)


### Задание 7*

Изучите содержимое файла console.tf. Откройте terraform console, выполните следующие задания:

1. Напишите, какой командой можно отобразить второй элемент списка test_list.
2. Найдите длину списка test_list с помощью функции length(<имя переменной>).
3. Напишите, какой командой можно отобразить значение ключа admin из map test_map.
4. Напишите interpolation-выражение, результатом которого будет: "John is admin for production server based on OS ubuntu-20-04 with X vcpu, Y ram and Z virtual disks", используйте данные из переменных test_list, test_map, servers и функцию length() для подстановки значений.
В качестве решения предоставьте необходимые команды и их вывод.

### Ответ:

1. 
```
> local.test_list[1]
"staging"
```
2. 
```
> length(local.test_list)
3
```
3. 
```
> local.test_map["admin"]
"John"
```
4. 
```
> "${ local.test_map["admin"] } is admin for ${ local.test_list[2] } server based on OS ${ local.servers["stage"]["image"] } with X vcpu, Y ram and Z virtual disks"
"John is admin for production server based on OS ubuntu-20-04 with X vcpu, Y ram and Z virtual disks"
```