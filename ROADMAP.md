# DEXTR Commander — Public Project Roadmap

This roadmap defines the work required to present DEXTR Commander as a credible, auditable open-source MCP host-control project.

## 1. Public project identity
- [x] Establish a concise product description.
- [ ] Add project badges for build, security checks, license, Rust, MCP, and release.
- [ ] Add a concise “Why DEXTR Commander” section.
- [ ] Add a clear “What DEXTR Commander is not” section.
- [ ] Add a short real-world demo.

## 2. Developer onboarding
- [ ] Rewrite the README around a 60-second quick start.
- [ ] Document prerequisites and supported runtime assumptions.
- [ ] Document stdio and Streamable HTTP usage with runnable examples.
- [ ] Add troubleshooting guidance.
- [ ] Document development and validation commands.

## 3. Architecture and MCP integration
- [ ] Document the trust boundary and execution path.
- [ ] Document MCP tools, transports, request lifecycle, and error behavior.
- [ ] Document the recommended authenticated gateway architecture.
- [ ] Provide integration examples for MCP clients.
- [ ] Keep the host executor independent from gateway-specific infrastructure.

## 4. Security hardening
- [x] Keep secrets and deployment state outside Git.
- [x] Provide a repository secret audit script.
- [ ] Complete authentication and authorization for remote HTTP exposure.
- [ ] Make authorization codes single-use.
- [ ] Add rate limiting.
- [ ] Restrict arbitrary shell execution or replace it with an explicit command policy.
- [ ] Define and enforce file-access authorization.
- [ ] Add replay protection and request auditing.
- [ ] Document the threat model and security invariants.
- [ ] Add automated dependency and static security checks.

## 5. CI and reproducibility
- [ ] Add CI for format, check, test, clippy, release build, and security audit.
- [ ] Keep CI reproducible and independent of production infrastructure.
- [ ] Publish validation results with releases.
- [ ] Evaluate artifact provenance/attestation for release artifacts.

## 6. Community and governance
- [x] Add contribution guidance.
- [ ] Add Code of Conduct.
- [ ] Add support/troubleshooting entry point.
- [ ] Define issue and pull-request expectations.
- [ ] Add issue templates where useful.
- [ ] Add a security disclosure path that does not require public issue disclosure.

## 7. Release discipline
- [ ] Establish semantic versioning and release notes.
- [ ] Publish a first polished public release.
- [ ] Maintain CHANGELOG.md.
- [ ] Record security-impacting changes explicitly.
- [ ] Publish reproducible release/build instructions.

## 8. Visitor-facing quality bar
A new visitor should be able to answer, without reading the source:
1. What is DEXTR Commander?
2. Why would I use it?
3. How do I run it locally?
4. How do I connect an MCP client?
5. What authority does it have over the host?
6. What security controls are required before remote exposure?
7. How can I verify the implementation?
8. How can I contribute?

## Target public architecture

```text
                         MCP Client
                             |
                             v
                    DEXTR Gateway
                             |
             Authentication / Authorization
                             |
               Rate Limit / Replay Protection
                             |
                             v
                    DEXTR Commander
                         /       \
                        v         v
               execute_command  read_file
                        \         /
                         v       v
                            wmw
```

The gateway is a security boundary. DEXTR Commander itself is not a sandbox and must not be described as one.

## Execution order

### Phase P0 — Public foundation
README, roadmap, architecture, MCP guide, deployment guide, security/threat model, community files.

### Phase P1 — Verification
CI, security scanning, dependency checks, release validation, reproducible examples.

### Phase P2 — Remote security
Authentication, authorization, single-use authorization codes, rate limiting, replay protection, command/file authorization.

### Phase P3 — Release
CHANGELOG, tagged release, release notes, artifact integrity/provenance, polished examples.

### Phase P4 — Ecosystem
Integrator guides, examples, issue templates, operational runbooks, compatibility matrix.

## Current priority

The immediate priority is P0. Remote exposure hardening in P2 remains a prerequisite for describing the HTTP deployment as suitable for untrusted networks.


## P5 — Установка «из коробки»

Цель: превратить DEXTR Commander из исходного проекта в самостоятельный устанавливаемый продукт, который сторонний пользователь может скачать, установить на Linux-компьютер, настроить и подключить к MCP-клиенту без сборки исходного кода.

### P5.1 — Распространение
- [ ] Публиковать готовые исполняемые файлы для поддерживаемых архитектур.
- [ ] Публиковать контрольные суммы релизных файлов.
- [ ] Определить поддерживаемые версии Linux.
- [ ] Сформировать понятную страницу релиза с инструкцией установки.
- [ ] Оставить сборку из исходников как отдельный путь для разработчиков.

### P5.2 — Установщик
- [ ] Создать официальный установщик DEXTR Commander.
- [ ] Проверять совместимость системы перед установкой.
- [ ] Устанавливать исполняемые файлы в стандартное расположение.
- [ ] Создавать отдельного системного пользователя `dextr`.
- [ ] Создавать каталоги конфигурации, состояния и журналов.
- [ ] Устанавливать системную службу.
- [ ] Проверять результат установки.
- [ ] Предоставить безопасное удаление.

### P5.3 — Первичная настройка
После установки пользователь должен пройти минимальную настройку:
- [ ] выбрать локальное или удалённое подключение;
- [ ] определить сетевой способ подключения;
- [ ] создать или зарегистрировать клиента;
- [ ] настроить проверку доступа;
- [ ] проверить работу MCP;
- [ ] выполнить безопасную диагностическую команду;
- [ ] получить понятный итоговый статус.

### P5.4 — Политика безопасности по умолчанию
- [ ] Запретить опасные операции по умолчанию.
- [ ] Ввести явную политику разрешённых команд.
- [ ] Ввести явную политику доступа к файлам.
- [ ] Запускать службу с минимально необходимыми правами.
- [ ] Не требовать `root` без явной необходимости.
- [ ] Отдельно документировать операции, требующие повышенных прав.
- [ ] Не превращать установку «из коробки» в открытый удалённый shell.

### P5.5 — Управление установленной системой
Предоставить понятные операции:
- [ ] запуск;
- [ ] остановка;
- [ ] перезапуск;
- [ ] проверка состояния;
- [ ] просмотр журналов;
- [ ] проверка конфигурации;
- [ ] диагностика подключения;
- [ ] обновление;
- [ ] удаление.

### P5.6 — MCP-подключение
- [ ] Предоставить готовый пример локального подключения.
- [ ] Предоставить готовый пример подключения через Tailscale.
- [ ] Предоставить готовый пример подключения через внешний шлюз.
- [ ] Документировать реальные адреса и пути подключения для официальной инфраструктуры.
- [ ] Не публиковать секреты, ключи и учётные данные.
- [ ] Проверять подключение после первоначальной настройки.

### P5.7 — Обновление и восстановление
- [ ] Поддержать безопасное обновление установленной версии.
- [ ] Проверять целостность загруженного релиза.
- [ ] Сохранять пользовательскую конфигурацию при обновлении.
- [ ] Документировать откат на предыдущую версию.
- [ ] Документировать восстановление после неудачного обновления.

### P5.8 — Пользовательский путь

Целевой сценарий:

```text
Скачать DEXTR Commander
        |
        v
Запустить установщик
        |
        v
Проверка системы
        |
        v
Установка службы
        |
        v
Первичная настройка
        |
        v
Проверка MCP
        |
        v
Подключение клиента
        |
        v
DEXTR Commander готов
```

Пользователь не должен быть обязан собирать Rust-проект из исходников для обычной установки.

### P5.9 — Критерий готовности

P5 считается завершённым, когда новый пользователь на поддерживаемой Linux-системе может:

1. скачать официальный релиз;
2. установить DEXTR Commander;
3. запустить службу;
4. выполнить первоначальную настройку;
5. подключить MCP-клиент;
6. пройти проверку доступа;
7. выполнить разрешённую диагностическую операцию;
8. обновить или удалить систему по официальной инструкции.

При этом установка по умолчанию не должна предоставлять неограниченный удалённый доступ к операционной системе.
