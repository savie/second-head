export type CalendarCreateEventInput = {
  summary: string;
  description?: string;
  location?: string;
  start: { dateTime: string; timeZone?: string };
  end: { dateTime: string; timeZone?: string };
};

export type CalendarCreateEventResult = {
  provider: "GOOGLE_CALENDAR";
  calendar_id: string;
  event_id: string;
  html_link: string | null;
  status: string | null;
};

export type CalendarConnector = {
  connector_id: "google_calendar";
  capability: "calendar";
  createEvent(
    accessToken: string,
    input: CalendarCreateEventInput,
    eventId: string,
  ): Promise<{ result?: CalendarCreateEventResult; httpStatus?: number; errorCode?: string }>;
};

export const googleCalendarConnector: CalendarConnector = {
  connector_id: "google_calendar",
  capability: "calendar",
  async createEvent(accessToken, input, eventId) {
    const event = {
      id: eventId,
      summary: input.summary.trim(),
      ...(input.description?.trim() ? { description: input.description.trim() } : {}),
      ...(input.location?.trim() ? { location: input.location.trim() } : {}),
      start: input.start,
      end: input.end,
    };

    const response = await fetch(
      "https://www.googleapis.com/calendar/v3/calendars/primary/events?sendUpdates=none",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(event),
      },
    );

    const body = await response.json().catch(() => ({}));

    if (!response.ok) {
      return {
        httpStatus: response.status,
        errorCode: response.status === 401 || response.status === 403
          ? "R4_GOOGLE_CALENDAR_WRITE_REJECTED"
          : response.status === 409
            ? "R4_GOOGLE_EVENT_ID_CONFLICT"
            : "R4_GOOGLE_CREATE_EVENT_FAILED",
      };
    }

    return {
      result: {
        provider: "GOOGLE_CALENDAR",
        calendar_id: "primary",
        event_id: body.id ?? eventId,
        html_link: body.htmlLink ?? null,
        status: body.status ?? null,
      },
    };
  },
};

export const connectorRegistry = {
  google_calendar: googleCalendarConnector,
} as const;
