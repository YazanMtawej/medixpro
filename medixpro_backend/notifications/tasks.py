from celery import shared_task


@shared_task
def send_notification(user_id, title, message):

    from .models import Notification

    Notification.objects.create(

        user_id=user_id,
        title=title,
        message=message

    )
