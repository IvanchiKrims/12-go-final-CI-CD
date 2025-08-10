# Stage 1: Build stage — сборка Go-приложения
FROM golang:1.23 AS builder

# Рабочая директория внутри контейнера
WORKDIR /app

# Копируем зависимости для кеширования
COPY go.mod go.sum ./
RUN go mod download

# Копируем весь код
COPY . .

# Собираем статический бинарник для Linux 
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app main.go parcel.go

# Stage 2: Минимальный runtime-образ
FROM alpine:latest

# Рабочая директория в контейнере
WORKDIR /root/

# Копируем бинарник из builder-стейджа
COPY --from=builder /app/app .

# Копируем базу данных
COPY tracker.db .

# Запускаем приложение и проверяем
CMD ["./app"]
