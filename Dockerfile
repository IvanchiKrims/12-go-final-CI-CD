FROM golang:1.23.0 AS builder

# Рабочая директория внутри контейнера
WORKDIR /app

# Копируем модули для кэширования зависимостей
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходники
COPY . .

# Собираем статический бинарник
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app main.go parcel.go

# Минимальный образ для запуска
FROM alpine:latest

WORKDIR /root/

# Копируем бинарник из builder-образа
COPY --from=builder /app/app .

# Копируем базу данных (если нужна в контейнере)
COPY tracker.db ./tracker.db

# Запуск приложения
CMD ["./app"]
