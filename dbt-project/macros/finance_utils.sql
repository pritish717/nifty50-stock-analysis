{% macro safe_divide(numerator, denominator) %}
    CASE
        WHEN {{ denominator }} IS NULL OR {{ denominator }} = 0 THEN NULL
        ELSE {{ numerator }} / {{ denominator }}
    END
{% endmacro %}
