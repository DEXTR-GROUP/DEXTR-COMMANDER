# Автоматический запуск DEXTR Commander

Служба `dextr-http.service` предназначена для постоянной работы DEXTR Commander как системной службы Linux.

## Установка

После сборки:

```bash
sudo install -m 0755 target/release/dextr-http /usr/local/bin/dextr-http
sudo install -m 0644 systemd/dextr-http.service /etc/systemd/system/dextr-http.service
sudo systemctl daemon-reload
sudo systemctl enable dextr-http.service
sudo systemctl start dextr-http.service
```

После `enable` служба будет запускаться автоматически при загрузке системы.

## Проверка

```bash
systemctl is-enabled dextr-http.service
systemctl is-active dextr-http.service
systemctl status dextr-http.service --no-pager
```

Ожидаемое состояние:

```text
enabled
active
```

## Проверка после перезагрузки

```bash
sudo reboot
```

После загрузки:

```bash
systemctl is-active dextr-http.service
```

Если состояние снова `active`, автоматический запуск работает.

## Восстановление после сбоя

Служба автоматически перезапускает процесс после аварийного завершения:

```text
DEXTR Commander
      |
      X
      |
      v
systemd
      |
      v
перезапуск
```

Количество быстрых повторных запусков ограничено, чтобы неисправная служба не создавала бесконечный цикл.

## Сетевой порядок запуска

Служба зависит от `network-online.target`. Systemd учитывает готовность сетевой подсистемы перед запуском DEXTR.

Служба сама по себе не является сетевым средством защиты. Правила удалённого доступа определяются отдельной конфигурацией.

## Ошибка запуска

```bash
systemctl status dextr-http.service --no-pager
journalctl -u dextr-http.service --no-pager -n 100
```

При ошибке конфигурации или разрешений DEXTR не должен переходить к небезопасному режиму.

## Критерий готовности

Установка считается завершённой только после проверки:

1. служба установлена;
2. автозапуск включён;
3. служба работает;
4. MCP доступен согласно конфигурации;
5. после перезагрузки служба запускается автоматически.
