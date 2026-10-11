.pragma library

// Open-Meteo: free, no API key, HTTPS. Only the searched name and the chosen
// coordinates are sent.
const GEOCODING = "https://geocoding-api.open-meteo.com/v1/search"
const FORECAST = "https://api.open-meteo.com/v1/forecast"

function getJson(url, done) {
    const xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== XMLHttpRequest.DONE)
            return
        if (xhr.status !== 200) {
            done(null)
            return
        }
        try {
            done(JSON.parse(xhr.responseText))
        } catch (e) {
            done(null)
        }
    }
    xhr.open("GET", url)
    xhr.send()
}

// done(list or null): [{name, detail, latitude, longitude}]
function searchPlaces(query, language, done) {
    const url = GEOCODING + "?count=8&format=json&name=" + encodeURIComponent(query)
              + "&language=" + encodeURIComponent(language)
    getJson(url, function(data) {
        if (!data) {
            done(null)
            return
        }
        done((data.results || []).map(function(r) {
            return {
                name: r.name,
                detail: [r.admin1, r.country].filter(function(x) { return x }).join(", "),
                latitude: r.latitude,
                longitude: r.longitude
            }
        }))
    })
}

// done(current or null): {temperature, code, isDay}
function current(latitude, longitude, done) {
    const url = FORECAST + "?latitude=" + latitude + "&longitude=" + longitude
              + "&current=temperature_2m,weather_code,is_day&timezone=auto"
    getJson(url, function(data) {
        if (!data || !data.current) {
            done(null)
            return
        }
        done({
            temperature: Math.round(data.current.temperature_2m),
            code: data.current.weather_code,
            isDay: data.current.is_day === 1
        })
    })
}

// WMO weather interpretation codes -> emoji
function emoji(code, isDay) {
    if (code === 0) return isDay ? "☀️" : "🌙"
    if (code <= 2) return isDay ? "🌤️" : "☁️"
    if (code === 3) return "☁️"
    if (code <= 48) return "🌫️"
    if (code <= 57) return "🌦️"
    if (code <= 67) return "🌧️"
    if (code <= 77) return "🌨️"
    if (code <= 82) return "🌧️"
    if (code <= 86) return "🌨️"
    return "⛈️"
}
