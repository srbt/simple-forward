FROM php:8.2-cli

COPY entrypoint.php /entrypoint.php

CMD ["-S", "0.0.0.0:8080", "/entrypoint.php"]
