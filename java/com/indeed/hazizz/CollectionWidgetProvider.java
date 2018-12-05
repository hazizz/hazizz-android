package com.indeed.hazizz;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.widget.RemoteViews;

import com.indeed.hazizz.Activities.AuthActivity;
import com.indeed.hazizz.Activities.MainActivity;
import com.indeed.hazizz.Communication.POJO.Response.CustomResponseHandler;
import com.indeed.hazizz.Communication.POJO.Response.POJOerror;
import com.indeed.hazizz.Communication.POJO.Response.getTaskPOJOs.POJOgetTask;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class CollectionWidgetProvider extends AppWidgetProvider {

    public static final String WIDGET_REFRESHBUTTON = "com.indeed.hazizz.WIDGET_REFRESHBUTTON";
    public static final String WIDGET_OPENAPPBUTTON = "com.indeed.hazizz.WIDGET_OPENAPPBUTTON";

    public static final String ACTION_VIEW_DETAILS =
            "com.company.android.ACTION_VIEW_DETAILS";
    public static final String EXTRA_ITEM =
            "com.company.android.CollectionWidgetProvider.EXTRA_ITEM";

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager,
                         int[] appWidgetIds) {

        for(int i = 0; i < appWidgetIds.length; i++) {


            int widgetId = appWidgetIds[i];

            Intent intent = new Intent(context, CollectionWidgetService.class);
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId);

            RemoteViews widgetView = new RemoteViews(context.getPackageName(), R.layout.hazizz_widget);

            appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, widgetView.getLayoutId());

            widgetView.setRemoteAdapter(R.id.widget_stack, intent);
            widgetView.setEmptyView(R.id.widget_stack, R.id.widget_info);

            Intent detailIntent = new Intent(ACTION_VIEW_DETAILS);
            PendingIntent pIntent = PendingIntent.getBroadcast(context, 0, detailIntent, PendingIntent.FLAG_UPDATE_CURRENT);
            widgetView.setPendingIntentTemplate(R.id.widget_stack, pIntent);

            Intent buttonIntent = new Intent(WIDGET_REFRESHBUTTON);
            PendingIntent pendingIntent = PendingIntent.getBroadcast(context, 0, buttonIntent, PendingIntent.FLAG_UPDATE_CURRENT);
            widgetView.setOnClickPendingIntent(R.id.button_refresh, pendingIntent);

        //    buttonIntent = new Intent(WIDGET_OPENAPPBUTTON);
        //    pendingIntent = PendingIntent.getBroadcast(context, 0, buttonIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        //    widgetView.setOnClickPendingIntent(R.id.button_openapp, pendingIntent);

            intent = new Intent(context, AuthActivity.class);
            pendingIntent = PendingIntent.getActivity(context, 0, intent, 0);
            widgetView.setOnClickPendingIntent(R.id.button_openapp, pendingIntent);

            widgetView.setInt(R.id.button_refresh, "setImageResource", R.drawable.ic_refresh_grey);
            widgetView.setInt(R.id.button_openapp, "setImageResource", R.drawable.ic_open_app_grey);

            appWidgetManager.updateAppWidget(widgetId, widgetView);
            Log.e("hey", "looping");
        }
        Log.e("hey", "updateing");

        super.onUpdate(context, appWidgetManager, appWidgetIds);
    }

    @Override
    public void onReceive(Context context, Intent intent) {

        if(intent.getAction().equals(ACTION_VIEW_DETAILS)) {
            POJOgetTask article = (POJOgetTask)intent.getSerializableExtra(EXTRA_ITEM);
            if(article != null) {
                // Handle the click here.
                // Maybe start a details activity?
                // Maybe consider using an Activity PendingIntent instead of a Broadcast?
            }
        }
        Log.e("hey", "RECIEVED");

        if (WIDGET_REFRESHBUTTON.equals(intent.getAction())) {
           // String str = intent.getAction();
            final AppWidgetManager mgr = AppWidgetManager.getInstance(context);
            final ComponentName cn = new ComponentName(context, CollectionWidgetProvider.class);
            mgr.notifyAppWidgetViewDataChanged(mgr.getAppWidgetIds(cn), R.id.widget_stack);
            Log.e("hey", "CLICK REFRESH BUTTON");
        }
        if (WIDGET_OPENAPPBUTTON.equals(intent.getAction())) {
            // String str = intent.getAction();
            final AppWidgetManager mgr = AppWidgetManager.getInstance(context);
            final ComponentName cn = new ComponentName(context, CollectionWidgetProvider.class);
            mgr.notifyAppWidgetViewDataChanged(mgr.getAppWidgetIds(cn), R.id.widget_stack);
            Log.e("hey", "CLICK REFRESH BUTTON");
        }

        super.onReceive(context, intent);
    }
}