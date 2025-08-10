FROM golang:1.22-alpine

# Рабочая директория
WORKDIR /app

# Устанавливаем зависимости, включая sqlite (если нужно, но modernc.org/sqlite — чистый Go, так что не нужен)
# RUN apk add --no-cache gcc musl-dev  # Не нужен, т.к. CGO отключен

# Копируем go.mod и go.sum для кэширования зависимостей
COPY go.mod go.sum ./

RUN go mod download

# Копируем исходники
COPY *.go ./

# Копируем базу данных внутрь образа
COPY tracker.db ./tracker.db

# Собираем статический бинарь (CGO отключён)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /my_app main.go parcel.go

# Запускаем приложение
CMD ["/my_app"]
