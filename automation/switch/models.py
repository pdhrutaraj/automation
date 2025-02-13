from django.db import models

class Switch(models.Model):
    name = models.CharField(max_length=100, unique=True)
    is_on = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.name} - {'ON' if self.is_on else 'OFF'}"

