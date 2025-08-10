# Используем golang образ с версией 1.23.0 для сборки
FROM golang:1.23.0 AS builder

# Рабочая директория внутри контейнера
WORKDIR /app

# Копируем go.mod и go.sum для кеширования зависимостей
COPY go.mod go.sum ./

# Скачиваем зависимости
RUN go mod download

# Копируем весь исходный код
COPY . .

# Собираем бинарник с нужными флагами (статическая сборка для linux amd64)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /main main.go

# Используем легковесный образ для запуска приложения
FROM alpine:latest

WORKDIR /root/

# Копируем собранный бинарник из этапа builder
COPY --from=builder /main .

# Если нужна база данных в контейнере, копируем её
COPY tracker.db ./tracker.db

# Запуск приложения
CMD ["./main"]
