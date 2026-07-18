// =========================================================================
// TYPES & INTERFACES
// =========================================================================

interface AddressComponent {
	long_name: string;
	short_name: string;
	types: string[];
}

/**
 * Clean, non-optional interface for a single geocoded result item.
 * Prevents "no matching index signature for type 'number'" compilation errors.
 */
interface GeocodedResult {
	formatted_address: string;
	address_components?: AddressComponent[];
	geometry: {
		location: {
			lat: number;
			lng: number;
		};
	};
}

interface GeocoderResponse {
	results?: GeocodedResult[];
}

interface DirectionsResponse {
	routes?: Array<{
		legs?: Array<{
			distance: {
				text: string;
				value: number;
			};
			duration: {
				text: string;
				value: number;
			};
		}>;
	}>;
}

interface AddressDetails {
	extendedAddress: string;
	streetAddress: string;
	addressLocality: string; // Resolves to the correct City/Town
	addressRegion: string; // Resolves to State (e.g., Haryana)
	postalCode: string;
	addressCountry: string;
}

// Request Payload Contracts
type MapAction =
	| { action: "getPlaceSuggestions"; params: { inputToken: string } }
	| { action: "processLocationAndMetrics"; params: LocationAndMetricsParams }
	| { action: "processPinDropMetrics"; params: PinDropParams };

interface LocationAndMetricsParams {
	originLat: number;
	originLng: number;
	destinationQuery: string;
}

interface PinDropParams {
	originLat: number;
	originLng: number;
	pinLat: number;
	pinLng: number;
}

// =========================================================================
// HELPERS
// =========================================================================

function parseRequestPayload(e: GoogleAppsScript.Events.DoPost): MapAction {
	if (!e.postData || !e.postData.contents) {
		throw new Error("Empty request body");
	}
	return JSON.parse(e.postData.contents) as MapAction;
}

function jsonSuccess(data: object): GoogleAppsScript.Content.TextOutput {
	return ContentService.createTextOutput(JSON.stringify({ success: true, ...data })).setMimeType(
		ContentService.MimeType.JSON,
	);
}

function jsonError(message: string): GoogleAppsScript.Content.TextOutput {
	return ContentService.createTextOutput(JSON.stringify({ success: false, error: message })).setMimeType(
		ContentService.MimeType.JSON,
	);
}

/**
 * Boundary Validator: Checks if a geocoded address is physically inside Haryana, India.
 */
function isWithinHaryana(result: GeocodedResult): boolean {
	if (!result || !result.address_components) return false;
	return result.address_components.some((component: AddressComponent) => {
		const isStateField = component.types.includes("administrative_area_level_1");
		const isHaryana = component.long_name === "Haryana" || component.short_name === "HR";
		return isStateField && isHaryana;
	});
}

/**
 * Highly reliable helper that extracts the actual municipal city/town name from
 * the formatted_address string by looking at the segment directly preceding the State/PIN block.
 */
function extractCityFromFormattedAddress(formattedAddress: string): string {
	if (!formattedAddress) return "";

	const parts = formattedAddress.split(",").map((p) => p.trim());
	let stateIndex = -1;

	// Iterate backward to locate the State block (e.g., "Haryana 124001")
	for (let i = parts.length - 1; i >= 0; i--) {
		const part = parts[i].toLowerCase();
		if (
			part.includes("haryana") ||
			part.includes(" hr") ||
			part === "hr" ||
			/\b1[23]\d{4}\b/.test(part) // Matches Haryana PIN codes starting with 12 or 13
		) {
			stateIndex = i;
			break;
		}
	}

	// The element directly to the left of the State block is almost always the municipal city/district
	if (stateIndex > 0) {
		let cityCandidate = parts[stateIndex - 1];
		// Clean up descriptive prefixes commonly added by Google Maps
		cityCandidate = cityCandidate.replace(/^(tehsil|district|distt\.?)\s+/i, "").trim();
		return cityCandidate;
	}

	return "";
}

/**
 * Deep-parses address structures using structured fallbacks and a natural text parsing cascade
 * to resolve the exact City or District name when Google skips or mislabels the standard 'locality' field.
 */
function parseAddressDetails(result: GeocodedResult): AddressDetails {
	const details: AddressDetails = {
		extendedAddress: "",
		streetAddress: "",
		addressLocality: "",
		addressRegion: "HR",
		postalCode: "",
		addressCountry: "IN",
	};

	if (!result || !result.address_components) return details;

	let locality = "";
	let postalTown = "";
	let adminArea3 = ""; // Sub-district / Tehsil (e.g., Bahadurgarh, Sampla)
	let adminArea2 = ""; // District (e.g., Jhajjar, Rohtak, Charkhi Dadri)
	let sublocality1 = "";
	let sublocality2 = "";
	let sublocality = "";
	let neighborhood = "";
	let route = "";
	let streetNumber = "";
	let premise = "";

	result.address_components.forEach((component: AddressComponent) => {
		const types = component.types;
		if (types.includes("locality")) {
			locality = component.long_name;
		} else if (types.includes("postal_town")) {
			postalTown = component.long_name;
		} else if (types.includes("administrative_area_level_3")) {
			adminArea3 = component.long_name;
		} else if (types.includes("administrative_area_level_2")) {
			adminArea2 = component.long_name;
		} else if (types.includes("sublocality_level_1")) {
			sublocality1 = component.long_name;
		} else if (types.includes("sublocality_level_2")) {
			sublocality2 = component.long_name;
		} else if (types.includes("sublocality")) {
			sublocality = component.long_name;
		} else if (types.includes("neighborhood")) {
			neighborhood = component.long_name;
		} else if (types.includes("route")) {
			route = component.long_name;
		} else if (types.includes("street_number")) {
			streetNumber = component.long_name;
		} else if (types.includes("premise")) {
			premise = component.long_name;
		} else if (types.includes("administrative_area_level_1")) {
			details.addressRegion = component.long_name;
		} else if (types.includes("postal_code")) {
			details.postalCode = component.long_name;
		} else if (types.includes("country")) {
			details.addressCountry = component.short_name;
		}
	});

	// 1. Resolve structured candidate
	const structuredLocality = locality || postalTown || adminArea3 || adminArea2 || sublocality1 || sublocality || "";

	// 2. Extract city/town from the user-facing formatted address string
	const formattedAddressCity = extractCityFromFormattedAddress(result.formatted_address);

	// 3. Double-Verification: Match text-parsed city against structured components to find the best match
	if (formattedAddressCity) {
		const cleanFormatted = formattedAddressCity.toLowerCase().replace(/[^a-z0-9]/g, "");
		const cleanLocality = locality.toLowerCase().replace(/[^a-z0-9]/g, "");
		const cleanPostalTown = postalTown.toLowerCase().replace(/[^a-z0-9]/g, "");
		const cleanAdmin3 = adminArea3.toLowerCase().replace(/[^a-z0-9]/g, "");
		const cleanAdmin2 = adminArea2.toLowerCase().replace(/[^a-z0-9]/g, "");

		if (cleanFormatted === cleanLocality) {
			details.addressLocality = locality;
		} else if (cleanFormatted === cleanPostalTown) {
			details.addressLocality = postalTown;
		} else if (cleanFormatted === cleanAdmin3) {
			details.addressLocality = adminArea3;
		} else if (cleanFormatted === cleanAdmin2) {
			details.addressLocality = adminArea2;
		} else {
			// Trust the formatted address string representation as the ultimate source of truth
			details.addressLocality = formattedAddressCity;
		}
	} else {
		details.addressLocality = structuredLocality;
	}

	// Build the primary street address lines
	const streetParts = [streetNumber, premise, route].filter(Boolean);
	details.streetAddress = streetParts.join(", ");

	// Build the extended address lines, avoiding duplicating the chosen city name
	const extendedParts = [sublocality2, sublocality1, neighborhood]
		.filter(Boolean)
		.filter((part) => part !== details.addressLocality);

	details.extendedAddress = extendedParts.join(", ");

	return details;
}

// =========================================================================
// PRIMARY ENTRYPOINT & ROUTER (doPost)
// =========================================================================

export function doPost(e: GoogleAppsScript.Events.DoPost): GoogleAppsScript.Content.TextOutput {
	try {
		const payload = parseRequestPayload(e);
		const { action } = payload;

		switch (action) {
			case "getPlaceSuggestions":
				return jsonSuccess({
					suggestions: getPlaceSuggestions(payload.params.inputToken),
				});

			case "processLocationAndMetrics":
				return handleLocationAndMetrics(payload.params);

			case "processPinDropMetrics":
				return handlePinDropMetrics(payload.params);

			default: {
				const exhaustiveCheck: never = action;
				return jsonError(`Unknown action: ${exhaustiveCheck}`);
			}
		}
	} catch (err) {
		const message = err instanceof Error ? err.message : String(err);
		return jsonError(message);
	}
}

// =========================================================================
// LOGIC HANDLERS
// =========================================================================

function getPlaceSuggestions(inputToken: string): string[] {
	if (!inputToken || inputToken.length < 3) return [];
	try {
		const response = Maps.newGeocoder().setRegion("in").geocode(inputToken) as GeocoderResponse;
		if (!response.results) return [];

		return response.results.filter(isWithinHaryana).map((r: GeocodedResult) => r.formatted_address);
	} catch {
		return [];
	}
}

function handleLocationAndMetrics(params: LocationAndMetricsParams): GoogleAppsScript.Content.TextOutput {
	try {
		if (!params.destinationQuery) throw new Error("Missing destinationQuery");
		if (params.originLat === undefined || params.originLng === undefined) {
			throw new Error("Missing origin coordinates");
		}

		const geocode = Maps.newGeocoder().setRegion("in").geocode(params.destinationQuery) as GeocoderResponse;
		if (!geocode.results || geocode.results.length === 0) {
			throw new Error("Unresolved address");
		}

		const result = geocode.results[0];

		if (!isWithinHaryana(result)) {
			throw new Error("Selected address must be within Haryana.");
		}

		const targetLat = result.geometry.location.lat;
		const targetLng = result.geometry.location.lng;
		const addressDetails = parseAddressDetails(result);

		return calculateMatrixMetrics(
			params.originLat,
			params.originLng,
			targetLat,
			targetLng,
			result.formatted_address,
			addressDetails,
		);
	} catch (e) {
		const message = e instanceof Error ? e.message : String(e);
		return jsonError(message);
	}
}

function handlePinDropMetrics(params: PinDropParams): GoogleAppsScript.Content.TextOutput {
	try {
		const pinLat = params.pinLat !== undefined ? params.pinLat : 28.5278681;
		const pinLng = params.pinLng !== undefined ? params.pinLng : 76.0837316;

		if (params.originLat === undefined || params.originLng === undefined) {
			throw new Error("Missing origin coordinates");
		}

		const response = Maps.newGeocoder().reverseGeocode(pinLat, pinLng) as GeocoderResponse;
		if (!response.results || response.results.length === 0) {
			throw new Error("Could not reverse geocode coordinates");
		}

		const result = response.results[0];

		if (!isWithinHaryana(result)) {
			throw new Error("Pinned location must be within Haryana.");
		}

		const addressDetails = parseAddressDetails(result);

		return calculateMatrixMetrics(
			params.originLat,
			params.originLng,
			pinLat,
			pinLng,
			result.formatted_address,
			addressDetails,
		);
	} catch (e) {
		const message = e instanceof Error ? e.message : String(e);
		return jsonError(message);
	}
}

function calculateMatrixMetrics(
	originLat: number,
	originLng: number,
	targetLat: number,
	targetLng: number,
	targetAddress: string,
	addressDetails: AddressDetails,
): GoogleAppsScript.Content.TextOutput {
	try {
		const directions = Maps.newDirectionFinder()
			.setOrigin(originLat, originLng)
			.setDestination(`${targetLat},${targetLng}`)
			.setMode(Maps.DirectionFinder.Mode.DRIVING)
			.getDirections() as DirectionsResponse;

		let distance = "N/A";
		let duration = "N/A";

		if (directions.routes && directions.routes.length > 0) {
			const route = directions.routes[0].legs?.[0];
			if (route) {
				distance = route.distance.text;
				duration = route.duration.text;
			}
		}

		return jsonSuccess({
			address: targetAddress,
			lat: targetLat,
			lng: targetLng,
			distance: distance,
			duration: duration,
			addressDetails: addressDetails,
		});
	} catch (e) {
		return jsonError("Matrix calculation failed");
	}
}

// =========================================================================
// EXPOSE TO ESBUILD IIFE GLOBAL SCOPE
// =========================================================================
(globalThis as any).doPost = doPost;
