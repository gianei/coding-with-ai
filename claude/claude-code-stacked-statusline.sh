input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name')
effort=$(echo "$input" | jq -r '(.effort.level // "high") | (.[0:1] | ascii_upcase) + .[1:]')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Ctx
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
pct_int=$(echo "$used_pct" | awk '{v=$1; if(v>100) v=100; printf "%.0f", v}')
ctx_filled=$((pct_int / 10))
if [ $pct_int -gt 0 ] && [ $ctx_filled -eq 0 ]; then ctx_filled=1; fi
if [ $pct_int -lt 24 ]; then ctx_fg=32; elif [ $pct_int -lt 90 ]; then ctx_fg=33; else ctx_fg=31; fi

# 5hr usage
usage_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0')
usage_int=$(printf '%.0f' "$usage_pct")
use_filled=$((usage_int / 10))
if [ $usage_int -gt 0 ] && [ $use_filled -eq 0 ]; then use_filled=1; fi
if [ $usage_int -lt 70 ]; then use_fg=34; elif [ $usage_int -lt 90 ]; then use_fg=33; else use_fg=31; fi

# Weekly (may not exist on enterprise)
has_weekly=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$has_weekly" ]; then
  weekly_int=$(printf '%.0f' "$has_weekly")
  if [ $weekly_int -lt 70 ]; then wk_fg=32; elif [ $weekly_int -lt 90 ]; then wk_fg=33; else wk_fg=31; fi
fi

# Stacked bar (top=Ctx, bottom=Use)
use_bg=$((use_fg + 10))
sbar=""
i=0
while [ $i -lt 10 ]; do
  if [ $i -lt $ctx_filled ] && [ $i -lt $use_filled ]; then
    sbar="${sbar}$(printf '\033[%sm\033[%sm' $ctx_fg $use_bg)▀"
  elif [ $i -lt $ctx_filled ]; then
    sbar="${sbar}$(printf '\033[%sm\033[48;5;239m' $ctx_fg)▀"
  elif [ $i -lt $use_filled ]; then
    sbar="${sbar}$(printf '\033[38;5;239m\033[%sm' $use_bg)▀"
  else
    sbar="${sbar}$(printf '\033[38;5;239m\033[48;5;239m')▀"
  fi
  i=$((i + 1))
done

# Ctx/Use [bar] ctx%/use% [ · wk%]
wk_suffix=""
if [ -n "$has_weekly" ]; then
  wk_suffix=" · $(printf '\033[%sm' $wk_fg)${weekly_int}%$(printf '\033[0m')"
fi
combo="$(printf '\033[2m')Ctx/Use$(printf '\033[0m') ${sbar}$(printf '\033[0m') $(printf '\033[%sm' $ctx_fg)${pct_int}%$(printf '\033[0m')/$(printf '\033[%sm' $use_fg)${usage_int}%$(printf '\033[0m')${wk_suffix}"

# Reset times (only show what exists)
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
reset_display=""
if [ -n "$five_reset" ]; then
  fr=$(date -r "$five_reset" "+%l%p" | tr -d ' ')
  reset_txt="${fr}"
  if [ -n "$seven_reset" ]; then
    sr=$(date -r "$seven_reset" "+%a %l%p" | tr -s ' ')
    reset_txt="${reset_txt} | ${sr}"
  fi
  reset_display=" $(printf '\033[2m')(${reset_txt})$(printf '\033[0m')"
elif [ -n "$seven_reset" ]; then
  sr=$(date -r "$seven_reset" "+%a %l%p" | tr -s ' ')
  reset_display=" $(printf '\033[2m')(${sr})$(printf '\033[0m')"
fi

# Git
git_display=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" -c core.fileMode=false branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" -c core.fileMode=false rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    if ! git -C "$cwd" -c core.fileMode=false diff --quiet 2>/dev/null || ! git -C "$cwd" -c core.fileMode=false diff --cached --quiet 2>/dev/null; then
      git_display=" | $(printf '\033[33m')${branch} ±$(printf '\033[0m')"
    else
      git_display=" | $(printf '\033[32m')${branch} ✓$(printf '\033[0m')"
    fi
  fi
fi

printf '%s  %s%s\n%s' "$(printf '\033[36m')${model} | ${effort}$(printf '\033[0m')" "${combo}" "${reset_display}" "$(printf '\033[32m')${cwd}$(printf '\033[0m')${git_display}"
