from django.core.management.base import BaseCommand, CommandError
from django.utils import timezone

from payments.services import build_settlements


class Command(BaseCommand):
    help = "Build/refresh monthly doctor payout settlements (0.2 × receipt × handled visits)."

    def add_arguments(self, parser):
        now = timezone.now()
        parser.add_argument("--year", type=int, default=now.year)
        parser.add_argument("--month", type=int, default=now.month)

    def handle(self, *args, **opts):
        year, month = opts["year"], opts["month"]
        if not 1 <= month <= 12:
            raise CommandError("month must be between 1 and 12")

        settlements = build_settlements(year, month)
        if not settlements:
            self.stdout.write(self.style.WARNING(
                f"No due payouts for {year}-{month:02d} (nothing completed & paid, or all already paid)."
            ))
            return

        self.stdout.write(self.style.SUCCESS(f"Payouts for {year}-{month:02d}:"))
        total = 0
        for s in settlements:
            total += s.total_amount
            self.stdout.write(
                f"  doctor={s.doctor} handled={s.handled_count} owed={s.total_amount} "
                f"currency={s.currency_id} status={s.status}"
            )
        self.stdout.write(self.style.SUCCESS(f"Total owed this run: {total}"))
