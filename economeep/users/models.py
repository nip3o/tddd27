from django.db import models
from django.contrib.auth.models import User
from django.utils.translation import ugettext_lazy as _

from payments.models import Category


class Budget(models.Model):
    class Meta:
        verbose_name = _('budget')
        verbose_name_plural = _('budgets')

    def __unicode__(self):
        return "%d/%d" % (self.month_start_date.month, self.month_start_date.year)

    month_start_date = models.DateField(_('month start date'))
    user = models.ForeignKey(User)


class BudgetEntry(models.Model):
    class Meta:
        verbose_name = _('budget entry')
        verbose_name_plural = _('budget entries')

    def __unicode__(self):
        return "%s, %.2f" % (unicode(self.category), self.amount)

    amount = models.DecimalField(decimal_places=2, max_digits=12)
    category = models.ForeignKey(Category)
    budget = models.ForeignKey(Budget, related_name='budget_entries')
